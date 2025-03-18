module ActionView::Helpers::TranslationHelper # rubocop:disable Lint/ConstantDefinitionInBlock
  alias_method :original_translate, :translate

  def translate(key, **)
    value = original_translate(key, **)

    is_missing_translation = value.is_a?(String) && value.include?('class="translation_missing"')
    if is_missing_translation
      value = extract_inner_content(value)
    end

    if moirai_edit_enabled?
      @key_finder ||= Moirai::KeyFinder.new

      render(partial: "moirai/translation_files/form",
        locals: {key: scope_key_by_partial(key),
                 locale: I18n.locale,
                 is_missing_translation: is_missing_translation,
                 value: value})
    else
      value
    end
  end

  alias_method :t, :translate

  def moirai_edit_enabled?
    return false unless Moirai.enable_inline_editing.present?

    instance_exec(params: defined?(params) ? (params || {}) : {}, &Moirai.enable_inline_editing)
  end

  private

  def extract_inner_content(html)
    match = html.match(/<[^>]+>([^<]*)<\/[^>]+>/)
    match ? match[1] : nil
  end
end
