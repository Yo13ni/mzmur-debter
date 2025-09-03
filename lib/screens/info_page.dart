import 'package:flutter/material.dart';
// Optional: Uncomment if using google_fonts
// import 'package:google_fonts/google_fonts.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'መረጃ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            // Optional: Use Google Fonts
            // style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold, fontSize: 22),
          ),
        ),
        backgroundColor:  Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ስለ መተግበሪያው',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                        // Optional: Use Google Fonts
                        // style: GoogleFonts.notoSansEthiopic(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal.shade700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ይህ የመዝሙር መተግበሪያ በኢትዮጵያ ኦርቶዶክስ ተዋህዶ ቤተክርስቲያን ስር ለሚገኙ አገልጋዮች በሙሉ ለመዝሙር ደብተርነት የሚያገለግል ሲሆን ተጠቃሚዎች ግጥሞችን በምድቦች መደርደር፣ ተወዳጅ ግጥሞችን በመለየት እና አዳዲስ ግጥሞችን በመጨመር እንዲሁም መዝሙሮችን በመላላክ መጠቀም ይችላሉ።\nበልዑል እግዚአብሔር እርዳታ በጽርሐ ጽዮን አብማ ማርያም ኮከበ ጽባሕ ሰንበት ትምህርት ቤት መዝሙር ክፍል ለአገልግሎትነት ይውል ዘንድ ተሰራ። \n email:yoni13awoke@gmail.com \n telegram:@yo_uno\n2017 ዓ.ም' ,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}