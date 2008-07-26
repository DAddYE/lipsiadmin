module LipsiaSoft
  # Module containing the methods useful for ext/prototype
  module PrototypeHelper
    include ActionView::Helpers::JavaScriptHelper
    # Hide all open dialogs
    def hide_dialogs
      record "Ext.Msg.getDialog().hide()"
    end
    
    def update(html)
      call "Lipsiadmin.app.update", html, true
    end

    def load_menu(url)
      call "Lipsiadmin.app.loadMenu", url, 'GET', 'html', true
    end

    def show_errors_for(*objects)
      count   = objects.inject(0) {|sum, object| sum + object.errors.count }
      unless count.zero?
        error_messages = objects.map {|object| object.errors.full_messages.map {|msg| "<li>#{msg}</li>" } }
        record "Ext.Msg.show({
                  title:Lipsiadmin.locale.alert.title,
                  msg: '<ul>#{escape_javascript(error_messages.join)}</ul>',
                  buttons: Ext.Msg.OK,
                  minWidth: 400
                })"
      else
        record "Ext.Msg.alert(Lipsiadmin.locale.labels.compliments, Lipsiadmin.locale.labels.compliments_msg)"
      end
    end
    
    def show_message(title, message)
      title   = title.blank? ? "Lipsiadmin.locale.labels.compliments" : "'#{escape_javascript(title)}'"
      message = message.blank? ? "Lipsiadmin.locale.labels.compliments_msg" : "'#{escape_javascript(message)}'"
      record "Ext.Msg.alert(#{title},#{message})"
    end
  end
end