=begin
stfw Graphical Result Viewer

stfw Graphical Result Viewer APIs

OpenAPI spec version: 0.0.1
Contact: example@example.com
Generated by: https://github.com/swagger-api/swagger-codegen.git

=end
Rails.application.routes.draw do

  resources :apidocs, only: [:index]

  def add_swagger_route http_method, path, opts = {}
    full_path = path.gsub(/{(.*?)}/, ':\1')
    match full_path, to: "#{opts.fetch(:controller_name)}##{opts[:action_name]}", via: http_method
  end

  add_swagger_route 'POST', '//hooks/{hookId}', controller_name: 'webhook', action_name: 'add_hooks_with_id_using_post1'
  add_swagger_route 'GET', '//hooks', controller_name: 'webhook', action_name: 'get_hooks_using_get1'
  add_swagger_route 'GET', '//hooks/{hookId}', controller_name: 'webhook', action_name: 'get_hooks_with_id_using_get1'
  add_swagger_route 'GET', '//hooks/{hookId}/{run_id}', controller_name: 'webhook', action_name: 'get_hooks_with_run_id_using_get1'
end
