class ConnectionResult<E> {

  final  _success;
  bool get success => _success;
  
  Exception _ex;
  Exception get ex => _ex;

  String _errorMessage;
  String get errorMessage => _errorMessage;

  E _data;
  E get data => _data;

  ConnectionResult(this._success, {E data, Exception ex, String errorMessage}) {
    _data = data;
    _ex = ex;
    _errorMessage = errorMessage; 
  }

}