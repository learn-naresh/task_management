const updateTaskCardStatus = (taskId, newStatus) => {
  const taskCard = document.querySelector(`.task-card[data-task-id="${taskId}"]`);
  if (taskCard) {
    const statusElement = taskCard.querySelector('.status');
    if (statusElement) {
      statusElement.textContent = `Status: ${newStatus.charAt(0).toUpperCase() + newStatus.slice(1)}`;
    }
  }
};

document.addEventListener('turbo:load', () => {
  const columns = ['backlog', 'in_progress', 'done'];

  columns.forEach((column) => {
    const element = document.getElementById(column);

    new Sortable(element, {
      group: 'kanban',
      animation: 150,
      onEnd: (evt) => {
        const targetColumnId = evt.to.id;
        if (targetColumnId === column) {
          // Do nothing if dragged to the same column
          return;
        }

        let newStatus;
        switch (column) {
          case 'backlog':
            newStatus = targetColumnId === 'in_progress' ? 'in_progress' : 'done';
            break;
          case 'in_progress':
            newStatus = targetColumnId === 'done' ? 'done' : 'backlog';
            break;
          case 'done':
            newStatus = targetColumnId === 'in_progress' ? 'in_progress' : 'backlog';
            break;
          default:
            newStatus = '';
            break;
        }
        handleTaskMovement(evt.item, newStatus);
      },
    });
  });
});

const handleTaskMovement = async (item, newStatus) => {
  const taskId = item.dataset.taskId;
  console.log(`Moving task ${taskId} to ${newStatus}`);
  try {
    const response = await fetch(`/tasks/${taskId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
      },
      body: JSON.stringify({ task: { status: newStatus } }),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    console.log(data);
    updateTaskCardStatus(taskId, newStatus);

  } catch (error) {
    console.error('Error:', error);
  }
};