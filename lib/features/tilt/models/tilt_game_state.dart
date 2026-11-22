enum TiltStatus {
  ready,
  swinging,
  falling,
  settling,
  paused,
  gameOver,
}

extension TiltStatusX on TiltStatus {
  bool get isInteractive => this == TiltStatus.swinging;
  bool get isGameOver => this == TiltStatus.gameOver;
  bool get isPaused => this == TiltStatus.paused;
}
