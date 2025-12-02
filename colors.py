class Colors:
    RESET = '\033[0m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    BOLD = '\033[1m'

def get_status_color(status):
    if status == 'completed':
        return Colors.GREEN
    elif status == 'in_progress':
        return Colors.YELLOW
    elif status == 'planned':
        return Colors.BLUE
    else:
        return Colors.RESET
