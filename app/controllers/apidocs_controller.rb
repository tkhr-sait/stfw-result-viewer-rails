class ApidocsController < ActionController::Base
  include Swagger::Blocks

  swagger_root do
    key :swagger, '2.0'
    info do
      key :description, 'stfw Graphical Result Viewer APIs'
      key :version, '0.0.1'
      key :title, 'stfw Graphical Result Viewer'
      contact do
        key :name, 'tkhr.sait'
        key :url, 'http://'
        key :email, 'example@example.com'
      end
      license do
        key :name, 'Apache 2.0'
        key :url, 'http://www.apache.org/licenses/LICENSE-2.0.html'
      end
    end
    key :host, 'localhost:3000'
    key :basePath, '/'
    tags do
      key :name, 'webhook'
      key :description, 'stfw Graphical Result Viewer API'
    end
  end

  SWAGGERED_CLASSES = [
    WebhookController,
    Postdatum,
    self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end
