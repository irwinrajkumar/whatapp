class ChatModel {
  final String name;
  final String message;
  final String time;
  final String profilePic;
  final bool isGroup;
  final int unreadCount;

  ChatModel({
    required this.name,
    required this.message,
    required this.time,
    required this.profilePic,
    this.isGroup = false,
    this.unreadCount = 0,
  });
}

List<ChatModel> mockChats = [
  ChatModel(
    name: "John Doe",
    message: "Hey, how are you?",
    time: "10:30 AM",
    profilePic: "https://randomuser.me/api/portraits/men/1.jpg",
    unreadCount: 2,
  ),
  
  ChatModel(
    name: "Flutter Devs",
    message: "Alice: Check out the new UI updates!",
    time: "9:15 AM",
    profilePic: "https://randomuser.me/api/portraits/lego/1.jpg",
    isGroup: true,
  ),
  ChatModel(
    name: "Jane Smith",
    message: "See you tomorrow at the office.",
    time: "Yesterday",
    profilePic: "https://randomuser.me/api/portraits/women/2.jpg",
  ),
  ChatModel(
    name: "Project Group",
    message: "Bob: I've uploaded the documents.",
    time: "Yesterday",
    profilePic: "https://randomuser.me/api/portraits/lego/2.jpg",
    isGroup: true,
    unreadCount: 5,
  ),
  ChatModel(
    name: "Mom",
    message: "Did you eat?",
    time: "8:00 AM",
    profilePic: "https://randomuser.me/api/portraits/women/3.jpg",
  ),
  ChatModel(
    name: "Pizza Place",
    message: "Your order is on the way!",
    time: "Monday",
    profilePic: "https://randomuser.me/api/portraits/lego/3.jpg",
  ),
];
