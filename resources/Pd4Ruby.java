import java.awt.Dimension;
import java.awt.Insets;
import java.lang.reflect.Field;
import java.net.URL;

import org.zefer.pd4ml.PD4Constants;
import org.zefer.pd4ml.PD4ML;

public class Pd4Ruby {

	public static void main(String[] args) throws Exception {
		
		if ( args.length < 2 ) {
			System.out.println( "Usage: java -Xmx512m Pd4Php <url> <htmlWidth> <pageFormat> [TTFfontsDir]" );
		}
		
		Pd4Ruby converter = new Pd4Ruby();
		converter.generatePDF( args[0], args[1], args[2], args.length > 3 ? args[3] : null ); 
	}

	private void generatePDF(String inputUrl, String htmlWidth, String pageFormat, String fontsDir)
			throws Exception {

		PD4ML pd4ml = new PD4ML();
		pd4ml.setPageInsets(new Insets(10, 20, 10, 10)); 
		if (htmlWidth != null) {
			pd4ml.setHtmlWidth(Integer.parseInt(htmlWidth));
		}
		
		Class c = PD4Constants.class;
		Field f = c.getField( pageFormat );
		Dimension d = (Dimension)f.get( pd4ml );
		
		pd4ml.setPageSize(d); 

		if ( fontsDir != null && fontsDir.length() > 0 ) {
			pd4ml.useTTF( fontsDir, true );
		}			
		
		java.io.StringReader reader = new java.io.StringReader(inputUrl);
		
		pd4ml.render(reader, System.out);
	}
}
