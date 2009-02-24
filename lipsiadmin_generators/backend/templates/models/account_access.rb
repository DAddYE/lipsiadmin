class AccountAccess < Lipsiadmin::AccessControl::Base 

  roles_for :administrator do |role|
    # Shared Permission
    role.allow_all_actions "/backend/base"
    role.allow_all_actions "/backend/event_logs"
    
    role.project_module :Account do |project|
      project.menu :list,   "/backend/accounts.js" do |submenu|
        submenu.add :new, "/backend/accounts/new"
      end
    end
    
    # Please don't remove this comment! It's used for auto adding project modules
  end
  
  
end