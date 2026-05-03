enum PizzaPhotoStep {
  front,
  top,
  slice,
  bottom;

  String get title {
    switch (this) {
      case PizzaPhotoStep.front:
        return 'Pizza a boca de horno';
      case PizzaPhotoStep.top:
        return 'Pizza desde arriba';
      case PizzaPhotoStep.slice:
        return 'Pizza corte porcion';
      case PizzaPhotoStep.bottom:
        return 'Pizza cocción debajo';
    }
  }

  String get description {
    switch (this) {
      case PizzaPhotoStep.front:
        return 'Debe verse la pizza recien hecha sobre la pala en la entrada del horno';
      case PizzaPhotoStep.top:
        return 'Debe verse la pizza completa en todo su diámetro desde arriba';
      case PizzaPhotoStep.slice:
        return 'Debe verse el corte lateral de una porción independientemente del estilo de pizza';
      case PizzaPhotoStep.bottom:
        return 'Debe verse al menos parcialmente la cocción de la masa debajo';
    }
  }

  String get exampleImageUrl {
    switch (this) {
      case PizzaPhotoStep.front:
        return 'https://i.ibb.co/n2sYtLD/b8eab707322743000dc0cbeb211a500a33fc43af.jpg';
      case PizzaPhotoStep.top:
        return 'https://i.ibb.co/CKs7jkvD/569589abb736fba9fcf5d2f014c13243a7854c8d.jpg';
      case PizzaPhotoStep.slice:
        return 'https://i.ibb.co/4RbS9mVH/733255011dc93e0156a96a05823a61893d1bac11.jpg';
      case PizzaPhotoStep.bottom:
        return 'https://i.ibb.co/nMNCmZwc/6cacf9ccfc8592c764c292ff1893325a3d2a4b93.jpg';
    }
  }
}
