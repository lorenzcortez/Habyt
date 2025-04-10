export default class PageUtils {
    months = [
        'January', 'February', 'March', 'April', 'May', 'June', 
        'July', 'August', 'September', 'October', 'November', 'December'
    ];

    formatDate(theDate) {
        let d = new Date(theDate);
        return this.months[d.getMonth()] + ' ' + d.getDate() + ', ' + d.getFullYear();
    }

    getDateStr(theDate) {
        return String(theDate.getFullYear()) + '-' + String(theDate.getMonth() + 1).padStart(2, '0') + '-' + String(theDate.getDate()).padStart(2, '0');
    }
}