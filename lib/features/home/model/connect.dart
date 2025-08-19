class Connect {
  final String id; // Added for unique identification
  final String postName;
  final String replyUserName;
  final String postTitle;
  final DateTime dateTime;
  final ConnectStatus status; // New: to track status
  final bool isUser;

  Connect({
    required this.id,
    required this.postName,
    required this.replyUserName,
    required this.postTitle,
    required this.dateTime,
    this.status = ConnectStatus.pending, // Default status
    required this.isUser,
  });

  // Method to create a copy with updated status
  Connect copyWith({ConnectStatus? status}) {
    return Connect(id: id, postName: postName, replyUserName: replyUserName, postTitle: postTitle, dateTime: dateTime, isUser: isUser, status: status ?? this.status);
  }
}

enum ConnectStatus {
  pending,
  accepted,
  rejected,
  completed, // Assuming 'Completed' is a state of 'Accepted'
}
