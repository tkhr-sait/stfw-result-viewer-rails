class ApidocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '0.0.1'
      key :title, 'stfw Graphical Result Viewer'
      key :description, 'stfw Graphical Result Viewer APIs' \
                        ''
      contact do
        key :name, 'tkhr.sait'
      end
      license do
        key :name, 'Apache 2.0'
      end
    end
    key :host, '127.0.0.1'
    key :basePath, '/'
    key :consumes, ['application/json']
    key :produces, ['application/json']
  end

  SWAGGERED_CLASSES = [
    WebhookController,
    self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end
