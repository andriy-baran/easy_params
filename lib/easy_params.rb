# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'
require 'active_model'
require 'easy_params/types/generic'
require 'easy_params/types/collection'
require 'easy_params/types/struct'
require 'easy_params/validation'
require 'easy_params/base'
require 'easy_params/types'
require 'easy_params/version'

module EasyParams
  class Error < StandardError; end
  # Your code goes here...
end
