# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


class AddColumnAuthCredentialToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :auth_credential, :string, null: true, default: nil
  end
end
