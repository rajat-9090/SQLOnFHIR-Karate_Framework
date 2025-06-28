package SOF.utilities;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class TimeFormat {


    public static String getFormattedTimestamp() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy.MM.dd.HH.mm.ss");
        return LocalDateTime.now().format(formatter);
    }
}
