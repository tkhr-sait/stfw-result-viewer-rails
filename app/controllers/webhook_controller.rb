=begin
stfw Graphical Result Viewer

stfw Graphical Result Viewer APIs.

OpenAPI spec version: 0.0.1
Contact: tkhr.sait@gmail.com
Generated by: https://github.com/swagger-api/swagger-codegen.git

=end
require 'json'
require 'gviz'
require 'base64'

class WebhookController < ApplicationController

  def add_hooks_with_id_using_post1
    postdatum = Postdatum.new({hookId: params['hookId'], run_id: params['payload']['run']['run id'], payload: params.to_json})
    postdatum.save

    render json: {"message" => "yes, it worked"}
  end

  def get_hooks_using_get1

    render json: {"message" => "yes, it worked"}
  end

  def get_hooks_with_id_using_get1
    gv = Gviz.new
    rec = Postdatum.order(created_at: :desc).find_by(hookId: params['hookId'])
    Postdatum.where("hookId = ? and run_id = ?", params['hookId'], rec.run_id)
             .order(created_at: :asc).each { |data|
      json_data = JSON.parse(data.payload)

      if json_data['payload']['type'] == 'run' then
        pkey=""
        ukey=json_data['payload']['run']['run id']

      elsif json_data['payload']['type'] == 'scenario' then
        pkey=sprintf("%s+run",
                     json_data['payload']['run']['run id'])
        ukey=json_data['payload']['run']['scenario']['name']

      elsif json_data['payload']['type'] == 'bizdate' then
        pkey=sprintf("%s+run+%s",
                     json_data['payload']['run']['run id'],
                     json_data['payload']['run']['scenario']['name'])
        ukey=json_data['payload']['run']['scenario']['bizdate']['dirname']

      elsif json_data['payload']['type'] == 'process' then
        pkey=sprintf("%s+run+%s+%s",
                     json_data['payload']['run']['run id'],
                     json_data['payload']['run']['scenario']['name'],
                     json_data['payload']['run']['scenario']['bizdate']['dirname'])
        ukey=json_data['payload']['run']['scenario']['bizdate']['process']['dirname']

      end

      desc=sprintf("%s(%s)\n%s[%s]\nstart:%s\nend  :%s",
                    json_data['payload']['type'],
                    ukey,
                    json_data['payload']['status'],
                    json_data['payload']['processing time'],
                    json_data['payload']['start time'],
                    json_data['payload']['end time'])

      # https://www.graphviz.org/doc/info/colors.html
      color='white'
      if json_data['payload']['status'] == 'success' then
        color='palegreen'
      elsif json_data['payload']['status'] == 'error' then
        color='lightcoral'
      end

      if pkey != "" then
        key=sprintf("%s+%s", pkey, ukey)
        gv.add pkey.gsub(/[_+]/,"x").to_sym => key.gsub(/[_+]/,"x").to_sym
      else
        key=sprintf("%s+run",ukey)
      end
      gv.node key.gsub(/[_+]/,"x").to_sym, label: desc, shape: 'box', style: 'filled,rounded', fillcolor: color
      # plugin
      if json_data['payload']['type'] == 'process' then
        json_data['payload']['run']['scenario']['bizdate']['process']['plugin']['targets'].each { | target |
          childdesc=sprintf("%s(%s)\n%s[%s]\nstart:%s\nend  :%s",
                            json_data['payload']['run']['scenario']['bizdate']['process']['plugin']['type'],
                            target.keys[0],
                            target[target.keys[0]]['result'],
                            target[target.keys[0]]['processing time'],
                            target[target.keys[0]]['start time'],
                            target[target.keys[0]]['end time'])
          childcolor='white'
          if target[target.keys[0]]['result'] == 'success' then
            childcolor='palegreen'
          elsif target[target.keys[0]]['result'] == 'error' then
            childcolor='lightcoral'
          end
          childkey=sprintf("%s+%s",key,target.keys[0])
          gv.add key.gsub(/[_+]/,"x").to_sym => childkey.gsub(/[_+]/,"x").to_sym
          gv.node childkey.gsub(/[_+]/,"x").to_sym, label: childdesc, shape: 'box', style: 'filled,rounded', fillcolor: childcolor
        }
      end
    }
    gv.save "sample", :png
    io = File.open("sample.dot")
    data = io.read
    io = File.open("sample.png")
    #image = Base64.strict_encode64(io.read)
    @image = Base64.strict_encode64(io.read)
    render 'layouts/webhook'
    # render json: {"message" => "ok","data" => data,"image" => image}
  end
end