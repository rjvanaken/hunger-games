class Colors:
    RESET = '\033[0m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    ORANGE = '\033[38;5;208m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    BOLD = '\033[1m'

def get_status_color(status):
    status_lower = status.lower()  # Convert to lowercase for comparison
    if status_lower == 'completed':
        return Colors.GREEN
    elif status_lower == 'in_progress' or status_lower == 'in progress':
        return Colors.ORANGE
    elif status_lower == 'planned':
        return Colors.BLUE
    else:
        return Colors.RESET
