class Issue {
  final String id;
  final String text;

  Issue(this.id, this.text);

  Issue.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'];

  Map<String, dynamic> toJson() =>
    {
      'id': id,
      'text': text,
    };



  }


