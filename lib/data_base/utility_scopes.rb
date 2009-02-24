module Lipsiadmin
  module DataBase
    # This Module provides named scope for:
    # 
    # - Search records in a extjs way (but can reusable)
    # - Paginate records in a extjs way (but can be reusable)
    # - Add association to the model (used for search in dependents tables)
    # 
    #   Examples:
    #   
    #     invoices = current_account.store.invoices.with(:order).search(params)
    #     invoices_count = invoices.size
    #     invoices_paginated = invoices.paginate(params)
    # 
    module UtilityScopes
      def self.included(base)#:nodoc:
        base.class_eval do 
          named_scope :search, lambda { |params|
            order = params[:sort].blank? && params[:dir].blank? ? nil : "#{params[:sort]} #{params[:dir]}"
            conditions = nil

            if !params[:query].blank? && !params[:fields].blank?
              filters = params[:fields].split(",").collect { |f| "#{f} LIKE ?" }.compact
              conditions = [filters.join(" OR ")].concat((1..filters.size).collect { "%#{params[:query]}%" })
            end

            { :conditions => conditions }
          }

          named_scope :paginate, lambda { |params|
            order = params[:sort].blank? && params[:dir].blank? ? nil : "#{params[:sort]} #{params[:dir]}"
            { :order => order, :limit => params[:limit], :offset => params[:start] }
          }

          named_scope :with, lambda { |*associations| { :include => associations } }
        end
      end
    end
  end
end