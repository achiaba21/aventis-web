// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationAdapter extends TypeAdapter<Conversation> {
  @override
  final int typeId = 0;

  @override
  Conversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Conversation(
      id: fields[0] as int?,
      proprietaire: fields[1] as User?,
      locataire: fields[2] as User?,
      dateDebut: fields[3] as DateTime?,
      dateFin: fields[4] as DateTime?,
      active: fields[5] as bool?,
      bookingId: fields[6] as int?,
      messages: (fields[7] as List?)?.cast<ChatMessage>(),
      lastUpdated: fields[8] as DateTime?,
      lastMessage: fields[9] as ChatMessage?,
      unreadCount: fields[10] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Conversation obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.proprietaire)
      ..writeByte(2)
      ..write(obj.locataire)
      ..writeByte(3)
      ..write(obj.dateDebut)
      ..writeByte(4)
      ..write(obj.dateFin)
      ..writeByte(5)
      ..write(obj.active)
      ..writeByte(6)
      ..write(obj.bookingId)
      ..writeByte(7)
      ..write(obj.messages)
      ..writeByte(8)
      ..write(obj.lastUpdated)
      ..writeByte(9)
      ..write(obj.lastMessage)
      ..writeByte(10)
      ..write(obj.unreadCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
