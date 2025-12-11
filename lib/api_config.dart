class ApiConfig {
  // 全局唯一的 API 基础网址
  static const String baseUrl = 'http://'; //API

  // 您可以把所有的 API 端点 (endpoint) 也定义在这里，方便管理
  static const String getPlaylist = '/get_playlist.php';
  static const String renamePlaylist = '/renamesqlplaylist.php';
  static const String updateSongsNum = '/updatesongsnum.php';
  static const String updateAddState = '/updateaddstate.php';
  static const String fetchSongList = '/fetch_songlist.php';
  static const String songListOperate = '/songs_to_list_operate.php';
  static const String fetchSongDetail = '/fetch_songdetail.php';
  static const String sendVerification = '/send_verification.php';
  static const String inputVerification = '/input_verification.php';
  static const String getUsers = '/get_users.php';
  static const String insertUser = '/insert_user.php';
  static const String resetPassword = '/resetpassword.php';
  static const String login = '/login.php';
  static const String forgetPassword = '/forgetpassword.php';
  static const String searchMusic = '/searchmusic.php';
  static const String songsList = '/songs_list.php';
}