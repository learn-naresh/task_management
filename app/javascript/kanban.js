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
    if (element) {
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
    }
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

const showTaskModal = async (taskId) => {
  const modal = document.getElementById('taskModal');
  const modalTitle = document.getElementById('modalTitle');
  const modalContent = document.getElementById('modalContent');

  try {
    const response = await fetch(`/tasks/${taskId}`);
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const task = await response.json();
    modalTitle.textContent = task.title;
    modalContent.innerHTML = `
      <p><strong>Description:</strong> ${task.description}</p>
      <p><strong>Status:</strong> ${task.status}</p>
      <p><strong>Deadline:</strong> ${task.deadline}</p>
      <p><strong>Owner ID:</strong> ${task.user_id}</p>
      <p><strong>Assignee</strong> ${task.assigned_user_id}</p>
      <p><strong>Created At:</strong> ${task.created_at}</p>
      <p><strong>Updated At:</strong> ${task.updated_at}</p>
      <!-- Add more task details as needed -->
    `;

    modal.classList.remove('hidden');
  } catch (error) {
    console.error('Error fetching task details:', error);
  }
};

const closeTaskModal = () => {
  const modal = document.getElementById('taskModal');
  modal.classList.add('hidden');
};

document.getElementById('closeModal').addEventListener('click', closeTaskModal);

window.showTaskModal = showTaskModal;
window.closeTaskModal = closeTaskModal;
