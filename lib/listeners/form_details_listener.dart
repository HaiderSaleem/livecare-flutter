abstract class FormDetailsListener {
  onItemClick(int sectionIndex, int fieldIndex);

  onUpdateValue(int sectionIndex, int fieldIndex, dynamic value);

  onDeleteValue(int sectionIndex, int fieldIndex, int itemIndex);
}
