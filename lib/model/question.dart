class Question {
String id;
String text;

  /*Question(this.id, this.text);

  Question.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'];*/

  Question(Map<String, dynamic> data) {
    id = data['id'];
    text = data['text'];
  }

 /* Map<String, dynamic> toJson() =>
      {
        'id': id,
        'text': text,
      };*/
}
