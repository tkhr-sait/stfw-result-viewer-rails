class Postdatum < ApplicationRecord
  include Swagger::Blocks

  swagger_schema :Postdata do
    key :required, [:id, :hookId, :run_id]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :hookId do
      key :type, :string
    end
    property :run_id do
      key :type, :string
    end
    property :payload do
      key :type, :string
    end
    property :created_at do
      key :type, :string
    end
    property :updated_at do
      key :type, :string
    end
  end

end
