/// Tailles standard des boutons du design system Asfar Premium.
///
/// Alignées sur le prototype HTML (`.btn-sm`, `.btn` md, `.btn-lg`) :
/// padding asymétrique vertical/horizontal, fontSize et radius par taille.
enum ButtonSize {
  sm(paddingY: 9, paddingX: 14, fontSize: 13, radius: 10),
  md(paddingY: 14, paddingX: 18, fontSize: 16, radius: 14),
  lg(paddingY: 16, paddingX: 20, fontSize: 17, radius: 16);

  final double paddingY;
  final double paddingX;
  final double fontSize;
  final double radius;

  const ButtonSize({
    required this.paddingY,
    required this.paddingX,
    required this.fontSize,
    required this.radius,
  });
}
