require "date"
require 'action_view/helpers/tag_helper'
module Lipsiadmin
  module View
    module Helpers#:nodoc:
      # Returns text_area, text_field, password_field with 
      # a default extjs css style.
      # 
      module FormHelper
        def self.included(base)#:nodoc:
          base.alias_method_chain :text_area, :style
          base.alias_method_chain :text_field, :style
          base.alias_method_chain :password_field, :style
        end

        # Returns text_area with extjs style
        # alias for text_area, for use the original tag use:
        # 
        #   text_area_without_style
        # 
        def text_area_with_style(name, value = nil, options = {})
          options[:class] ||= "x-form-field"
          options[:style] ||= "width:100%;height:80px"
          text_area_without_style(name, value, options)
        end

        # Returns text_field with extjs style
        # alias for text_field, for use the original tag use:
        # 
        #   text_field_without_style
        #        
        def text_field_with_style(name, method, options = {})
          options[:class] ||= "x-form-text"
          options[:style] ||= "width:100%"
          text_field_without_style(name, method, options)
        end
        
        # Returns password_field with extjs style
        # alias for password_field, for use the original tag use:
        # 
        #   password_field_without_style
        #        
        def password_field_with_style(name, method, options = {})
          options[:class] ||= "x-form-text"
          options[:style] ||= "width:100%"
          password_field_without_style(name, method, options)
        end
      end

      # Returns text_area_tag, text_field_tag, password_field_tag with 
      # a default extjs css style.
      #      
      module FormTagHelper
        
        def self.included(base)#:nodoc:
          base.alias_method_chain :text_field_tag, :style
          base.alias_method_chain :text_area_tag, :style
          base.alias_method_chain :password_field_tag, :style
        end

        # Returns text_area_tag with extjs style
        # alias for text_area_tag, for use the original tag use:
        # 
        #   text_area_tag_without_style
        # 
        def text_area_tag_with_style(name, value = nil, options = {})
          options[:class] ||= "x-form-field"
          options[:style] ||= "width:100%;height:80px"
          text_area_tag_without_style(name, value, options)
        end

        # Returns text_field_tag with extjs style
        # alias for text_field_tag, for use the original tag use:
        # 
        #   text_field_tag_without_style
        # 
        def text_field_tag_with_style(name, value = nil, options = {})
          options[:class] ||= "x-form-text"
          options[:style] ||= "width:100%"
          text_field_tag_without_style(name, value, options)
        end
        
        # Returns password_field_tag with extjs style
        # alias for password_field_tag, for use the original tag use:
        # 
        #   password_field_tag_style
        # 
        def password_field_tag_with_style(name, value = nil, options = {})
          options[:class] ||= "x-form-text"
          options[:style] ||= "width:100%"
          password_field_tag_without_style(name, value, options)
        end
      end
      
      module DateHelper
        # Returns an ExtJs Calendar
        # 
        #   Examples:
        #     =ext_date_select :post, :created_at
        #       
        def ext_date_select(object_name, method, options = {}, html_options = {})
          InstanceTag.new(object_name, method, self, options.delete(:object)).to_ext_date_select_tag(options, html_options)
        end
      
        # Returns an ExtJs Calendar and a Time selector
        # 
        #   Examples:
        #     =ext_datetime_select :post, :updated_at
        #
        def ext_datetime_select(object_name, method, options = {}, html_options = {})
          InstanceTag.new(object_name, method, self, options.delete(:object)).to_ext_datetime_select_tag(options, html_options)
        end
      end

      module CountrySelectHelper
        # Return select and option tags for the given object and method, using country_options_for_select to generate the list of option tags.
        def country_select(object, method, priority_countries = nil, options = {}, html_options = {})
          InstanceTag.new(object, method, self, options.delete(:object)).to_country_select_tag(priority_countries, options, html_options)
        end
        # Returns a string of option tags for pretty much any country in the world. Supply a country name as +selected+ to
        # have it marked as the selected option tag. You can also supply an array of countries as +priority_countries+, so
        # that they will be listed above the rest of the (long) list.
        #
        # NOTE: Only the option tags are returned, you have to wrap this call in a regular HTML select tag.
        def country_options_for_select(selected = nil, priority_countries = nil)
          country_options = ""

          if priority_countries
            country_options += options_for_select(priority_countries, selected)
            country_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
          end

          return country_options + options_for_select(COUNTRIES, selected)
        end
        # All the countries included in the country_options output.
        COUNTRIES = ["Afghanistan", "Aland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola",
          "Anguilla", "Antarctica", "Antigua And Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria",
          "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin",
          "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegowina", "Botswana", "Bouvet Island", "Brazil",
          "British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia",
          "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China",
          "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo",
          "Congo, the Democratic Republic of the", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba",
          "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt",
          "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands (Malvinas)",
          "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia",
          "French Southern Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guernsey", "Guinea",
          "Guinea-Bissau", "Guyana", "Haiti", "Heard and McDonald Islands", "Holy See (Vatican City State)",
          "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran, Islamic Republic of", "Iraq",
          "Ireland", "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya",
          "Kiribati", "Korea, Democratic People's Republic of", "Korea, Republic of", "Kuwait", "Kyrgyzstan",
          "Lao People's Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libyan Arab Jamahiriya",
          "Liechtenstein", "Lithuania", "Luxembourg", "Macao", "Macedonia, The Former Yugoslav Republic Of",
          "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique",
          "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia, Federated States of", "Moldova, Republic of",
          "Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru",
          "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger",
          "Nigeria", "Niue", "Norfolk Island", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Palau",
          "Palestinian Territory, Occupied", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines",
          "Pitcairn", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russian Federation",
          "Rwanda", "Saint Barthelemy", "Saint Helena", "Saint Kitts and Nevis", "Saint Lucia",
          "Saint Pierre and Miquelon", "Saint Vincent and the Grenadines", "Samoa", "San Marino",
          "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore",
          "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa",
          "South Georgia and the South Sandwich Islands", "Spain", "Sri Lanka", "Sudan", "Suriname",
          "Svalbard and Jan Mayen", "Swaziland", "Sweden", "Switzerland", "Syrian Arab Republic",
          "Taiwan, Province of China", "Tajikistan", "Tanzania, United Republic of", "Thailand", "Timor-Leste",
          "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan",
          "Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom",
          "United States", "United States Minor Outlying Islands", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela",
          "Viet Nam", "Virgin Islands, British", "Virgin Islands, U.S.", "Wallis and Futuna", "Western Sahara",
          "Yemen", "Zambia", "Zimbabwe"] unless const_defined?("COUNTRIES")
      end

      class InstanceTag < ActionView::Helpers::InstanceTag#:nodoc:
        include CountrySelectHelper
        
        def to_ext_date_select_tag(options = {}, html_options = {})
          to_ext_datetime_select_tag({ :hideTime => true.to_l }.merge(options), html_options)
        end

        def to_ext_datetime_select_tag(options = {}, html_options = {})
          html_options = html_options.stringify_keys
          html_options = DEFAULT_FIELD_OPTIONS.merge(html_options)
          html_options["type"] = "hidden"
          html_options["value"] ||= value_before_type_cast(object)
          html_options["value"] &&= html_escape(html_options["value"])
          add_default_name_and_id(html_options)
          options = { :applyTo => html_options["id"], :dateFormat => I18n.t("extjs.dateFormat") }.merge(options)
          tag("input", html_options) +
          content_tag(:script, "new Ext.form.DateTimeField(#{options.to_json});", :type => Mime::JS)
        end
        
        def to_country_select_tag(priority_countries, options, html_options)
          html_options = html_options.stringify_keys
          add_default_name_and_id(html_options)
          value = value(object)
          content_tag("select",
            add_options(
              country_options_for_select(value, priority_countries),
              options, value
            ), html_options
          )
        end
      end

      module FormBuilder#:nodoc:
        def ext_date_select(method, options = {}, html_options = {})
          @template.ext_date_select(@object_name, method, options.merge(:object => @object), html_options)
        end

        def ext_datetime_select(method, options = {}, html_options = {})
          @template.ext_datetime_select(@object_name, method, options.merge(:object => @object), html_options)
        end
        
        def country_select(method, priority_countries = nil, options = {}, html_options = {})
          @template.country_select(@object_name, method, priority_countries, options.merge(:object => @object), html_options)
        end
      end
    end
  end
end