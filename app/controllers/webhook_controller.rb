=begin
stfw Graphical Result Viewer

stfw Graphical Result Viewer APIs.

OpenAPI spec version: 0.0.1
Contact: tkhr.sait@gmail.com
Generated by: https://github.com/swagger-api/swagger-codegen.git

=end
require 'json'
require 'yaml'
require 'gviz'
require 'base64'

class WebhookController < ApplicationController
  include Swagger::Blocks

  #------------------------------------------
  swagger_path '/hooks/{hookId}' do
    operation :post do
      key :tags, [
        'webhook'
      ]
      key :summary, '/hooks/{hookId} POST'
      key :operationId, 'addHooksWithIdUsingPOST_1'
      key :consumes, [
        'application/json',
        'application/x-yaml'
      ]
      key :produces, [
        'application/x-yaml'
      ]
      parameter do
        key :name, 'hookId'
        key :in, :path
        key :description, 'ID of Hook that needs to be add'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, 'payload'
        key :in, :body
        key :description, 'stfw webhook object that needs to be add'
        key :required, true
        schema do
          key :type, :object
        end
      end
      response 200 do
        key :description, 'OK'
        schema do
          key :type, :object
        end
      end
      response 400 do
        key :description, 'Invalid input'
        schema do
          key :type, :object
        end
      end
    end
  end
  #------------------------------------------
  def add_hooks_with_id_using_post1
    postdatum = Postdatum.new({hookId: params['hookId'], run_id: params['payload']['run']['run_id'], payload: params.to_json})
    postdatum.save

    render json: {"message" => "yes, it worked"}
  end

  #------------------------------------------
  swagger_path '/hooks' do
    operation :get do
      key :tags, [
        'webhook'
      ]
      key :summary, "/hooks GET"
      key :description, "Returns all Hooks"
      key :operationId, "getHooksUsingGet_1"
      response 200 do
        key :description, "Successful Operation"
      end
      response 404 do
        key :description, "Not Found"
      end
    end
  end
  #------------------------------------------
  def get_hooks_using_get1
    @array = []
    Postdatum.select("distinct hookId, run_id")
             .order(created_at: :desc).each { |data|
       @array << { hookId: data.hookId, run_id: data.run_id }
    }
    render 'layouts/webhooklist'
    #render json: {"message" => "ok", "data" => @array}
  end

  #------------------------------------------
  swagger_path '/hooks/{hookId}' do
    operation :get do
      key :tags, [
        'webhook'
      ]
      key :summary, "/hooks GET"
      key :description, "Returns all Hooks"
      key :operationId, "getHooksWithIdUsingGet_1"
      parameter do
        key :name, 'hookId'
        key :in, :path
        key :description, 'ID of Hook that needs to be add'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, "Successful Operation"
      end
      response 404 do
        key :description, "Not Found"
      end
    end
  end
  #------------------------------------------
  def get_hooks_with_id_using_get1

    # 最新の run_id を対象にする
    rec = Postdatum.order(created_at: :desc).find_by(hookId: params['hookId'])
    if rec == nil then
      render html: 'no data'
      return
    end
    _createGraph(rec.hookId,rec.run_id)

    io = File.open("sample.dot")
    data = io.read
    io = File.open("sample.png")
    @image = Base64.strict_encode64(io.read)
    render 'layouts/webhook'
    #image = Base64.strict_encode64(io.read)
    #render json: {"message" => "ok","data" => data,"image" => image}
  end

  #------------------------------------------
  swagger_path '/hooks/{hookId}/{run_id}' do
    operation :get do
      key :tags, [
        'webhook'
      ]
      key :summary, "/hooks GET"
      key :description, "Returns all Hooks"
      key :operationId, "getHooksWithRunIdUsingGet_1"
      parameter do
        key :name, 'hookId'
        key :in, :path
        key :description, 'ID of Hook that needs to be get'
        key :required, true
        key :type, :string
      end
      parameter do
        key :name, 'run_id'
        key :in, :path
        key :description, 'ID of run that needs to be get'
        key :required, true
        key :type, :string
      end
      response 200 do
        key :description, "Successful Operation"
      end
      response 404 do
        key :description, "Not Found"
      end
    end
  end
  #------------------------------------------
  def get_hooks_with_run_id_using_get1
    _createGraph(params['hookId'],params['run_id'])

    io = File.open("sample.dot")
    data = io.read
    io = File.open("sample.png")
    @image = Base64.strict_encode64(io.read)
    render 'layouts/webhook'
    #image = Base64.strict_encode64(io.read)
    #render json: {"message" => "ok","data" => data,"image" => image}
  end


  def _createGraph(hookId,run_id)
    gv = Gviz.new
    gv.global layout: "dot"
    
    @array = []
    Postdatum.where("hookId = ? and run_id = ?", hookId, run_id)
             .order(created_at: :asc).each { |data|
      json_data = JSON.parse(data.payload)
      @array << YAML.dump(json_data)

      id=json_data['payload']['id']
      parent_id=json_data['payload']['parent_id']
      run_id=json_data['payload']['run']['run_id']
      key = ""
      case json_data['payload']['type']
      when 'run' then
        key=run_id
      when 'scenario' then
        key=json_data['payload']['run']['scenario']['name']
      when 'bizdate' then
        key=json_data['payload']['run']['scenario']['bizdate']['dirname']
      when 'process' then
        key=json_data['payload']['run']['scenario']['bizdate']['process']['dirname']
      end


      desc=sprintf("%s(%s)\n%s[%s]\nstart:%s\nend  :%s",
                    json_data['payload']['type'],
                    key,
                    json_data['payload']['status'],
                    json_data['payload']['processing_time'],
                    json_data['payload']['start_time'],
                    json_data['payload']['end_time'])

      # https://www.graphviz.org/doc/info/colors.html
      color='white'
      if json_data['payload']['status'] == 'Success' then
        color='palegreen'
      elsif json_data['payload']['status'] == 'Error' then
        color='lightcoral'
      end

      if parent_id != run_id then
        gv.add parent_id.gsub(/[_+]/,"X").to_sym => id.gsub(/[_+]/,"X").to_sym
      end
      gv.node id.gsub(/[_+]/,"X").to_sym, label: desc, shape: 'box', style: 'filled,rounded', fillcolor: color
      # plugin
      if json_data['payload']['type'] == 'process' then
        json_data['payload']['run']['scenario']['bizdate']['process']['plugin']['targets'].each { | target |
          childdesc=sprintf("%s(%s)\n%s[%s]\nstart:%s\nend  :%s",
                            json_data['payload']['run']['scenario']['bizdate']['process']['plugin']['type'],
                            target.keys[0],
                            target[target.keys[0]]['result'],
                            target[target.keys[0]]['processing_time'],
                            target[target.keys[0]]['start_time'],
                            target[target.keys[0]]['end_time'])
          childcolor='white'
          if target[target.keys[0]]['result'] == 'Success' then
            childcolor='palegreen'
          elsif target[target.keys[0]]['result'] == 'Error' then
            childcolor='lightcoral'
          end
          childkey=sprintf("%s+%s",id,target.keys[0])
          gv.add id.gsub(/[_+]/,"X").to_sym => childkey.gsub(/[_+]/,"X").to_sym
          gv.node childkey.gsub(/[_+]/,"X").to_sym, label: childdesc, shape: 'box', style: 'filled,rounded', fillcolor: childcolor
        }
      end
    }
    gv.save "sample", :png
  end

end
