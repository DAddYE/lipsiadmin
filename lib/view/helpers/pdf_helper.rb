module Lipsiadmin
  module View
    module Helpers
      # This helper is necessary for when we generate some PDF
      # remember that basically pdf are standard html pages
      # and we use PD4ML for convert it in PDF. 
      # 
      # So for example is necessary have an header for all pdf page
      # and a footer.
      # 
      # Here you can find helpers for do that.
      # 
      module PdfHelper
        # Return the pd4ml header tag block
        def pdf_header(&block)
          html = <<-HTML
            <pd4ml:page.header>
              <div style="padding:0px 0px 100px 0px">
                #{capture(&block)}
              </div>
            </pd4ml:page.header>
          HTML
          concat(html)
        end
        
        # Return the pd4ml footer tag block
        def pdf_footer(&block)
          html = <<-HTML
            <pd4ml:page.footer>
              #{capture(&block) if block_given?}
              <div style="text-align:right;padding-top:10px">#{I18n.t("backend.general.page")} $[page] #{I18n.t("backend.general.of")} $[total]</div>
            </pd4ml:page.footer>
          HTML
          block_given? ? concat(html) : html
        end
        
        # Return the pd4ml page break tag
        def pdf_page_break
          "<pd4ml:page.break>"
        end
      end
    end
  end
end
      