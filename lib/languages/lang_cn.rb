# lang_cn.rb
# Simplified Chinese translation file. 
# Translation by Capitan Zhan ( www.cslog.cn )


module LocalizationSimplified
  About = {
    :lang => "cn",
    :updated => "2008-03-16"
  }

  class ActiveRecord
    # ErrorMessages to override default messages in 
    # +ActiveRecord::Errors::@@default_error_messages+
    # This plugin also replaces hardcoded 3 text messages 
    # :error_translation is inflected using the Rails 
    # inflector. 
    #
    # Remember to modify the Inflector with your localized translation
    # of "error" and "errors" in the bottom of this file
    # 
    ErrorMessages = {
      :inclusion           => "应被包含在",
      :exclusion           => "不能被包含在内",
      :invalid             => "无法通验证",
      :confirmation        => "和确认信息不一致",
      :accepted            => "必须被选中",
      :empty               => "不能为空",
      :blank               => "不能为空",# alternate formulation: "is required"
      :too_long            => "超长 (最长为 %d 字符)",
      :too_short           => "过短 (最少为 %d 字符)",
      :wrong_length        => "长度不对 (就为 %d 字符)",
      :taken               => "已经被占用",
      :not_a_number        => "非数字",
      #Jespers additions:
      :error_translation   => "个错误",
      :error_header        => "致使 %s 不能被保存",
      :error_subheader     => "下列表格有误:"
    }
  end

  # Texts to override +distance_of_time_in_words()+
  class DateHelper
    Texts = {
      :less_than_x_seconds => "少于 %d 秒钟",
      :half_a_minute       => "半分钟",
      :less_than_a_minute  => "少于一分钟",
      :one_minute          => "一分钟",
      :x_minutes           => "%d 分钟",
      :one_hour            => "约一小时",
      :x_hours             => "约 %d 小时",
      :one_day             => "一天",
      :x_days              => "%d 天",
      :one_month           => "1 个月",
      :x_months            => "%d 个月",
      :one_year            => "1 年",
      :x_years             => "%d 年"
    }

    # Rails uses Month names in Date and time select boxes 
    # (+date_select+ and +datetime_select+ )
    # Currently (as of version 1.1.6), Rails doesn't use daynames
    Monthnames     = [nil] + %w{一月 二月 三月 四月 五月 六月 七月 八月 九月 十月 十一月 十二}
    AbbrMonthnames = [nil] + %w{一月 二月 三月 四月 五月 六月 七月 八月 九月 十月 十一月 十二}
    Daynames       = %w{星期天 星期一 星期二 星期三 星期四 星期五 星期六}
    AbbrDaynames   = %w{周日 周一 周二 周三 周四 周五 周六}
    
    # Date and time format syntax explained in http://www.rubycentral.com/ref/ref_c_time.html#strftime
    # These are sent to strftime that Ruby's date and time handlers use internally
    # Same options as php (that has a better list: http://www.php.net/strftime )
    DateFormats = {
      :default  => "%Y-%m-%d",
      :short    => "%b %e",
      :long     => "%B %e, %Y"
    }

    TimeFormats = {
      :default  => "%a, %d %b %Y %H:%M:%S %z",
      :short    => "%d %b %H:%M",
      :long     => "%B %d, %Y %H:%M"
    }
    # Set the order of +date_select+ and +datetime_select+ boxes
    # Note that at present, the current Rails version only supports ordering of date_select boxes
    DateSelectOrder = {
      :order    => [:year, :month, :day] #default Rails is US ordered: :order => [:year, :month, :day]
    }
  end

  class NumberHelper
    # CurrencyOptions are used as default for +Number#to_currency()+
    # http://api.rubyonrails.org/classes/ActionView/Helpers/NumberHelper.html#M000449
    CurrencyOptions = {
      :unit      => "元",
      :separator => ".",             #unit separator (between integer part and fraction part)
      :delimiter => ",",             #delimiter between each group of thousands. Example: 1.234.567 
      :order     => [:number, :unit] #order is at present unsupported in Rails
      #to support for instance Danish format, the order is different: Unit comes last (ex. "1.234,00 dkr.")
    }
  end

  class ArrayHelper
    # Modifies +Array#to_sentence()+
    # http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/Array/Conversions.html#M000274
    ToSentenceTexts = {
      :connector => '和',
      :skip_last_comma => false
    }
  end
end


# Use the inflector below to pluralize "error" from
# @@default_error_messages[:error_translation] above (if necessary)
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person people'
#   inflect.uncountable %w( information )
# end
