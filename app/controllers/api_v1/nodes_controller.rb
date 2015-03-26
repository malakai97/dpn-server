require_relative '../../../app/presenters/api_v1/node_presenter'

class ApiV1::NodesController < ApplicationController
  include Authenticate

  def index
    @nodes = Node.all.collect do |node|
      ApiV1::NodePresenter.new(node)
    end

    output = {
      :count => @nodes.size,
      :results => @nodes
    }

    render json: output
  end

  def show
    node = Node.find_by_namespace(params[:namespace])
    if node.nil?
      render nothing: true, status: 404
    else
      @node = ApiV1::NodePresenter.new(node)
      render json: @node
    end
  end

  # This method is internal
  def create
    # Ensure that the request comes from the local node.
    if @requester.namespace != Rails.configuration.local_namespace
      render json: "Only allowed by local node.", status: 403
      return
    end

    expected_params = [:name, :namespace, :api_root, :ssh_pubkey,
      :replicate_from, :replicate_to, :restore_from, :restore_to,
      :protocols, :fixity_algorithms, :storage,
      :created_at, :updated_at, :private_auth_token
    ]

    unless expected_params.all? {|param| params.has_key?(param)}
      render nothing: true, status: 400
      return
    end

    unless params[:storage].respond_to?(:has_key?) && params[:storage].has_key?(:region) && params[:storage].has_key?(:type)
      render nothing: true, status: 400
      return
    end

    node = Node.new

    begin
      node.created_at = params[:created_at].to_time(:utc)
    rescue ArgumentError
      render nothing: true, status: 400
      return
    end

    node.name = params[:name]
    node.namespace = params[:namespace]
    node.api_root = params[:api_root]
    node.ssh_pubkey = params[:ssh_pubkey]
    node.replicate_to_nodes = Node.where(:namespace => params[:replicate_to])
    node.replicate_from_nodes = Node.where(:namespace => params[:replicate_from])
    node.restore_to_nodes = Node.where(:namespace => params[:restore_to])
    node.restore_from_nodes = Node.where(:namespace => params[:restore_from])
    node.protocols = Protocol.where(:name => params[:protocols])
    node.fixity_algs = FixityAlg.where(:name => params[:fixity_algorithms])
    node.storage_region = StorageRegion.find_by_name(params[:storage][:region])
    node.storage_type = StorageType.find_by_name(params[:storage][:type])
    node.private_auth_token = params[:private_auth_token]

    if node.save
      render nothing: true, content_type: "application/json", status: 201, location: api_v1_node_url(node)
    else
      if node.errors[:namespace].include?("has already been taken")
        render nothing: true, status: 409
      else
        render nothing: true, status: 400
      end
    end
  end


  # This method is internal
  def update
    # Ensure that the request comes from the local node.
    if @requester.namespace != Rails.configuration.local_namespace
      render json: "Only allowed by local node.", status: 403
      return
    end

    expected_params = [:name, :namespace, :api_root, :ssh_pubkey,
      :replicate_from, :replicate_to, :restore_from, :restore_to,
      :protocols, :fixity_algorithms, :storage,
      :created_at, :updated_at
    ]

    unless expected_params.all? {|param| params.has_key?(param)}
      render nothing: true, status: 400
      return
    end

    unless params[:storage].respond_to?(:has_key?) && params[:storage].has_key?(:region) && params[:storage].has_key?(:type)
      render nothing: true, status: 400
      return
    end

    node = Node.find_by_namespace(params[:namespace])
    if node.nil?
      render nothing: true, status: 404
      return
    end

    node.name = params[:name]
    node.api_root = params[:api_root]
    node.ssh_pubkey = params[:ssh_pubkey]
    node.replicate_to_nodes = Node.where(:namespace => params[:replicate_to])
    node.replicate_from_nodes = Node.where(:namespace => params[:replicate_from])
    node.restore_to_nodes = Node.where(:namespace => params[:restore_to])
    node.restore_from_nodes = Node.where(:namespace => params[:restore_from])
    node.protocols = Protocol.where(:name => params[:protocols])
    node.fixity_algs = FixityAlg.where(:name => params[:fixity_algorithms])
    node.storage_region = StorageRegion.find_by_name(params[:storage][:region])
    node.storage_type = StorageType.find_by_name(params[:storage][:type])

    if node.save
      render json: ApiV1::NodePresenter.new(node), status: 200
    else
      render nothing: true, status: 400
    end
  end


end
