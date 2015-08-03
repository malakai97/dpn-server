# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


# Validates that if a model has changed, at least one
# field other than its timestamps have changed.
class ChangeValidator < ActiveModel::Validator
  def validate(record)
    if record.changed?
      non_timestamp_changed_keys = record.changes.keys - ["updated_at", "created_at"]
      if non_timestamp_changed_keys.size == 0
        record.errors[:base] << "Timestamp changes are not sufficient to update this record."
      end
    end
  end
end