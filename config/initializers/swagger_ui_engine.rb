if Object.const_defined?('SwaggerUiEngine')
  SwaggerUiEngine.configure do |config|
    config.swagger_url = {
      v1: '/api/v1/swagger_doc.json',
    }
    config.model_rendering = 'schema'
  end
end