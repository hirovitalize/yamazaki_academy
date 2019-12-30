<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>
  # include ActiveModel::Validations
  # extends, includes

  # self settings
  # end of self settings

  # extensions
<% attributes.select(&:token?).each do |attribute| -%>
  has_secure_token<% if attribute.name != "token" %> :<%= attribute.name %><% end %>
<% end -%>
<% if attributes.any?(&:password_digest?) -%>
  has_secure_password
<% end -%>
  acts_as_paranoid
  stampable with_deleted: true
  has_paper_trail
  # end of extensions

  # associations
<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %><%= ', polymorphic: true' if attribute.polymorphic? %><%= ', required: true' if attribute.required? %>
<% end -%>
  # end of associations

  # enums
  # end of enums

  # alias
  # nested_attributes

  # validations
  # end of validations
end
<% end -%>
