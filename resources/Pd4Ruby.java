// For compile javac -cp pd4ml.jar Pd4Ruby.java
import java.awt.Dimension;
import java.awt.Insets;
import java.lang.reflect.Field;
import java.net.URL;

import org.zefer.pd4ml.PD4Constants;
import org.zefer.pd4ml.PD4ML;

public class Pd4Ruby {

  public static void main(String[] args) throws Exception {

    if ( args.length < 2 ) {
      System.out.println( "Usage: java -Xmx512m Pd4Ruby <url> <htmlWidth> <pageFormat> <landescape> [TTFfontsDir]" );
    }

    Pd4Ruby converter = new Pd4Ruby();
    converter.generatePDF( args[0], args[1], args[2], args[3], args.length > 4 ? args[4] : null ); 
  }

  private void generatePDF(String inputUrl, String htmlWidth, String pageFormat, String landescape, String fontsDir)
  throws Exception {

    PD4ML pd4ml = new PD4ML();
    pd4ml.setPageInsets(new Insets(15, 20, 10, 20)); 

    if (htmlWidth != null) {
      pd4ml.setHtmlWidth(Integer.parseInt(htmlWidth));
    }

    Class c = PD4Constants.class;
    Field f = c.getField( pageFormat );
    Dimension d = (Dimension)f.get( pd4ml );

    if (landescape.equals("true")){
      d = pd4ml.changePageOrientation(d); 
    }

    pd4ml.setPageSize(d); 

    pd4ml.setAuthorName("LipsiaSoft s.r.l."); 

    if ( fontsDir != null && fontsDir.length() > 0 ) {
      pd4ml.useTTF( fontsDir, true );
    }     

    java.io.StringReader reader = new java.io.StringReader(inputUrl);

    pd4ml.render(reader, System.out);
  }
}
