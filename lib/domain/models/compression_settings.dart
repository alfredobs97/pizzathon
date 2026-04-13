
class CompressionSettings {
  final int quality;
  final int maxWidth;
  final int maxHeight;

  const CompressionSettings({
    required this.quality,
    this.maxWidth = 1440,
    this.maxHeight = 1440,
  });

  factory CompressionSettings.defaultConfig() => const CompressionSettings(quality: 70);
}