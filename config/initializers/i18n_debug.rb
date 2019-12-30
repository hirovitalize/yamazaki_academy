if defined? I18n::Debug
  I18n::Debug.on_lookup = lambda do |key, result|
    return if key =~ /\.simple_form\./

    # I18nをdebugしたいときには↓をコメントイン
    #Rails.logger.debug("[i18n-debug][Missing]: #{key}") unless result
  end
end