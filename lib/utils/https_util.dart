class HttpsUtil {
  static String normalize(String value){
    String url = value.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
  
  return  url = 'https://www.google.com/search?q=$url';

  }
}