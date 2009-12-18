/* Pd4Ruby
 * Created for PDF::PD4ML Ruby library. This is a wrapper for the commercial
 * library PD4ML which converts HTML documents to PDF
 * 
 * Author: Nilesh Chaudhari
 * 
 * Released under MIT license
 *
 * For compile javac -cp pd4ml.jar Pd4Ruby.java
*/
 
import java.awt.Dimension;
import java.awt.Insets;
import java.lang.reflect.Field;
import java.net.URL;
import java.util.StringTokenizer;
 
import org.zefer.pd4ml.PD4Constants;
import org.zefer.pd4ml.PD4ML;
import org.zefer.pd4ml.PD4PageMark;
 
public class Pd4Ruby {
 
  public final static String USAGE = "Usage: java -Xmx512m Pd4Ruby --url <url> --file <file> \\\n" + 
    "  [--width <html_width>] \\\n" +
    "  [--pagesize <A1-A10|ISOB0-ISOB5|LEGAL|LETTER|LEDGER|NOTE|TABLOID>] \\\n" + 
    "  [--permissions <integer> --password <password>] \\\n" + 
    "  [--bookmarks <HEADINGS|ANCHORS>] \\\n" +
    "  [--orientation <PORTRAIT|LANDSCAPE>] \\\n" + 
    "  [--insets <T,L,B,R,><mm|pt>] \\\n" + 
    "  [--ttf <ttf_fonts_dir>] \\\n" +
    "  [--header '<html_text>'] \\\n" +
    "  [--footer '<html_text>'] \\\n" +
    "  [--debug]";
  
  public static void main(String[] args) throws Exception {
    
    String url = null;
    String file = null;
    int debug = 0;
    int width = 800;
    String pagesize = "A4";
    int permissions = 65532; // all permissions off by default
    String bookmarks = "HEADINGS";
    String orientation = "PORTRAIT";
    String insets = null;
    String ttf = null;
    String password = null;
    String header = null;
    String footer = null;
 
    boolean formatSet = false;
    
    for( int i = 0; i < args.length; i++ ) {
      
      if ( "--url".equals( args[i] ) ) {
        ++i;
        if (( i == args.length ) || ( args[i].startsWith("--") )) {
          System.out.println("invalid parameter: missing url");
          System.out.println( USAGE );
          return; 
        }
        url = args[i];
        continue;
      }
      
      if ( "--file".equals( args[i] ) ) {
        ++i;
        if (( i == args.length ) || ( args[i].startsWith("--") )) {
          System.out.println("invalid parameter: missing file");
          System.out.println( USAGE );
          return; 
        }
        file = args[i];
        continue;
      }
      
      if ( "--permissions".equals( args[i] ) ) {
        ++i;
        if ( i == args.length ) {
          System.out.println("invalid parameter: missing permissions number (a sum of single permission codes)");
          System.out.println( USAGE );
          return; 
        }
        permissions = Integer.parseInt(args[i]);
        continue;
      }
      
      if ( "--password".equals( args[i] ) ) {
        ++i;
        if ( i == args.length ) {
          System.out.println("invalid parameter: missing password");
          System.out.println( USAGE );
          return; 
        }
        password = args[i];
        continue;
      }
 
      if ( "--bookmarks".equals( args[i] ) ) {
        ++i;
        if ( i == args.length ) {
          System.out.println("invalid parameter: missing bookmark type (HEADINGS or ANCHORS)");
          System.out.println( USAGE );
          return; 
        }
        bookmarks = args[i];
        continue;
      }
 
      if ( "--orientation".equals( args[i] ) ) {
        ++i;
        if ( i == args.length ) {
          System.out.println("invalid parameter: missing orientation type (PORTRAIT or LANDSCAPE)");
          System.out.println( USAGE );
          return; 
        }
        orientation = args[i];
        continue;
      }
      
      if ( "--pagesize".equals( args[i] ) ) {
        ++i;
        if ( i == args.length ) {
          System.out.println("invalid parameter: missing page size");
          System.out.println( USAGE );
          return; 
        }
        pagesize = args[i];
        continue;
      }
 
      if ( "--insets".equals( args[i] ) ) {
        ++i;
        if ( i == args.length ) {
          System.out.println("invalid parameter: missing insets (for exampe: --insets 5,10,5,5mm)");
          System.out.println( USAGE );
          return; 
        }
        insets = args[i];
        continue;
      }
 
      if ( "--ttf".equals( args[i] ) ) {
        ++i;
        if ( i == args.length ) {
          System.out.println("invalid parameter: missing TTF fonts directory");
          System.out.println( USAGE );
          return; 
        }
        ttf = args[i];
        continue;
      }
      
      if ( "--header".equals( args[i] ) ) {
        ++i;
        if ( i == args.length ) {
          System.out.println("invalid parameter: missing header text");
          System.out.println( USAGE );
          return; 
        }
        header = args[i];
        continue;
      }
      
      if ( "--footer".equals( args[i] ) ) {
        ++i;
        if ( i == args.length ) {
          System.out.println("invalid parameter: missing footer text");
          System.out.println( USAGE );
          return; 
        }
        footer = args[i];
        continue;
      }
            
      if ( "--debug".equals( args[i] ) ) {
        debug = 1;
        continue;
      }
      
      if ( "--width".equals( args[i] ) ) {
        ++i;
        if ( i == args.length ) {
          System.out.println("invalid width: missing HTML width");
          System.out.println( USAGE );
          return; 
        }
        width = Integer.parseInt(args[i]);
        continue;
      }
 
      if ( args[i].startsWith("--")  ) {
        System.out.println("unknown parameter: " + args[i] );
        System.out.println( USAGE );
        return; 
      }
 
      System.out.println("unexpected parameter: " + args[i]);
      System.out.println( USAGE );
      return; 
    }
    
    if (( url == null ) && ( file == null)) {
      System.out.println("source is missing. Specify at least a url or a file.");
      System.out.println( USAGE );
      return;
    }
    
    Pd4Ruby converter = new Pd4Ruby();
    converter.generatePDF( url, file, width, pagesize, permissions, password, bookmarks, orientation, insets, ttf, header, footer, debug ); 
  }
 
  private void generatePDF(String inputUrl, String inputFile, int htmlWidth, String pageFormat, int permissions, String password, String bookmarks, String orientation, String insets, String fontsDir, String headerBody, String footerBody, int debug) throws Exception {
 
    PD4ML pd4ml = new PD4ML();
    
    if ( insets != null ) {
      StringTokenizer st = new StringTokenizer( insets, ",");
      try {
        int top = Integer.parseInt(st.nextToken());
        int left = Integer.parseInt(st.nextToken());
        int bottom = Integer.parseInt(st.nextToken());
        int right = Integer.parseInt(st.nextToken());
        String units = st.nextToken();
        Insets ins = new Insets(top, left, bottom, right);
        if ("mm".equalsIgnoreCase(units)) {
          pd4ml.setPageInsetsMM(ins);
        } else {
          pd4ml.setPageInsets(ins);
        }
      } catch (Exception e) {
        throw new Exception(
            "Invalid page insets (top, left, bottom, right, units): "
                + insets );
      }
    }
    
    pd4ml.setHtmlWidth(htmlWidth);
    pd4ml.setAuthorName("LipsiaSoft s.r.l.");
    
    Class c = PD4Constants.class;
    Field f = c.getField( pageFormat );
    Dimension d = (Dimension)f.get( pd4ml );
    
    if ("PORTRAIT".equalsIgnoreCase(orientation)) { 
      pd4ml.setPageSize(d); 
    } else { 
      pd4ml.setPageSize( pd4ml.changePageOrientation( d ) ); 
    }
    
    if ( permissions != -1 ) {
      if ( password != null ) {
        pd4ml.setPermissions(password, permissions, true);
      } else {
        pd4ml.setPermissions("empty", permissions, true);
      }
    }
    
    if ( bookmarks != null ) {
      if ( "ANCHORS".equalsIgnoreCase(bookmarks) ) {
        pd4ml.generateOutlines(false);
      } else if ( "HEADINGS".equalsIgnoreCase(bookmarks) ) {
        pd4ml.generateOutlines(true);
      }
    }
 
    if ( fontsDir != null && fontsDir.length() > 0 ) {
      pd4ml.useTTF( fontsDir, true );
    }
    
    if ( headerBody != null && headerBody.length() > 0 ) {
      PD4PageMark header = new PD4PageMark();
      header.setAreaHeight( -1 ); // autocompute
      header.setHtmlTemplate( headerBody ); // autocompute
      pd4ml.setPageHeader( header );
    }
    
    if ( footerBody != null && footerBody.length() > 0 ) {
      PD4PageMark footer = new PD4PageMark();
      footer.setAreaHeight( -1 ); // autocompute
      footer.setHtmlTemplate( headerBody ); // autocompute
      pd4ml.setPageFooter( footer );
    }
 
    if ( debug != 0 ) {
      pd4ml.enableDebugInfo();
    }
 
    if (inputFile != null) {
      pd4ml.render(("file:" + inputFile), System.out);
    } else if (inputUrl != null) { 
      pd4ml.render(new URL(inputUrl), System.out);
    }
  }
}

