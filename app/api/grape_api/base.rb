# frozen_string_literal: true

module GrapeApi
  class Base < Grape::API
    begin
      ActiveRecord::Base.connection.tables.map(&:classify).map(&:safe_constantize)
    rescue ActiveRecord::NoDatabaseError
      no_databases = true
    else
      no_databases = false
    end
    ApplicationRecord.descendants.each do |model|
      break if no_databases

      entity_assoc = ResourcesEntityFactory.create(model, true)
      entity = ResourcesEntityFactory.create(model, false)

      resource model.table_name, desc: model.model_name.human do
        desc "Searching #{model.model_name.human}",
             headers: { 'X-Access-Token' => { required: true } },
             entity: entity,
             response: { isArray: true, entity: entity }
        params do
          optional :page, type: Integer
          optional :per, type: Integer
          optional :q, type: Object, desc: 'ex: q[name_cont]=京都&q[s]=code+desc'
          optional :select, type: Array[String], desc: 'ex: select[]=code&select[]=name'
          optional :group, type: String
        end
        get do
          authenticate!

          fields = normalize_symbols(params[:select]).map { |f| ignore_nonexisted_column(f, model) }
          search = search_scope(model, params)
          if fields.present?
            search.select(* fields.map(&:to_s))
          else
            entity.represent search
          end
        end

        desc "Counting #{model.model_name.human}",
             headers: { 'X-Access-Token' => { required: true } },
             response: Integer
        params do
          optional :q, type: Object
        end
        get '/count' do
          authenticate!
          search_scope(model, params).count
        end

        desc "Fetching #{model.model_name.human}",
             headers: { 'X-Access-Token' => { required: true } },
             entity: entity_assoc,
             response: entity_assoc
        params do
          requires :id, type: Integer
          optional :includes, type: Array[String], desc: 'ex: q[name_cont]=京都&q[s]=code+desc'
        end
        get '/:id' do
          authenticate!

          options = {}
          fields_plus = normalize_symbols(params[:includes])
          fields_minus = normalize_symbols(entity_assoc.associations)
          options[:except] = fields_minus - fields_plus

          entity_assoc.represent model.find(params[:id]), options
        end

        desc "Creating #{model.model_name.human}",
             headers: { 'X-Access-Token' => { required: true } },
             entity: entity,
             response: entity
        params do
          requires model.model_name.singular, type: Object
        end
        post do
          authenticate!
          ar = model.new(params[model.model_name.singular])
          if !to_bool(params.fetch(:validate, true))
            ar.save(validate: false)
          else
            ar.save!
          end
          present ar, with: entity
        end

        desc "Bulk-updating #{model.model_name.human}",
             headers: { 'X-Access-Token' => { required: true } },
             response: TrueClass
        params do
          requires model.model_name.plural, type: Object
        end
        put '/update_all' do
          authenticate!
          ActiveRecord::Base.transaction do
            params[model.model_name.plural].each_value do |param|
              model.find(param[:id]).update!(param.except(:id))
            end
          end
        end

        desc "Updating #{model.model_name.human}",
             headers: { 'X-Access-Token' => { required: true } },
             response: TrueClass
        params do
          requires :id, type: Integer
          requires model.model_name.singular, type: Object
        end
        put '/:id' do
          authenticate!
          ar = model.find(params[:id])
          ar.assign_attributes(params[model.model_name.singular])
          if !to_bool(params.fetch(:validate, true))
            ar.save(validate: false)
          else
            ar.save!
          end
        end

        desc "Deleting #{model.model_name.human}",
             headers: { 'X-Access-Token' => { required: true } },
             entity: entity,
             response: entity
        params do
          requires :id, type: Integer
        end
        delete '/:id' do
          authenticate!
          present model.find(params[:id]).destroy!, with: entity
        end
      end
    end

    # /api/v1/swagger_doc.json
    add_swagger_documentation(
      info: {
        title: 'API',
        description: 'Specifications for json REST API of this application.'
      },
      api_version: 'v1'
    )

    route :any, '*path' do
      error! 'Not found. No such schema, maybe.', 404
    end
  end
end
