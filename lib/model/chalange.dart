class Challenge {
  final String id;
  final String text;

  Challenge(this.id, this.text);

  Challenge.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'];

  Map<String, dynamic> toJson() =>
    {
      'id': id,
      'text': text,
    };



  }


