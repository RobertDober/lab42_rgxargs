# frozen_string_literal: true

require 'ostruct'
class OpenStruct
  def deconstruct_keys(_keys)
    to_h
  end
end
# SPDX-License-Identifier: Apache-2.0
