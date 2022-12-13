import { LightningElement, track } from 'lwc';
import getUsers from '@salesforce/apex/CheckAvailabilityCtrl.getUsers'

const columns = [
    { label: 'Name', fieldName: 'name' },
    { label: 'Email', fieldName: 'email', type: 'email' }
];

export default class CheckAvailability extends LightningElement {
  @track startDateTime
  @track endDateTime
  users
  data
  columns = columns
  showSpinner
  searchStarted

  handleChangeStart(event) {
    this.startDateTime = event.target.value;
  }

  handleChangeEnd(event) {
    this.endDateTime = event.target.value;
  }
  
  async handleSearch(){
    this.showSpinner = true
    this.searchStarted = true
    this.users = await getUsers({
      startDate: this.startDateTime,
      endDate: this.endDateTime
    })
    this.data = this.users.map(u=>{
      return { 
        id: u.Id, 
        name: u.Name, 
        email: u.Email
      }
    })
    this.showSpinner = false
  }

  get noFound() {
    return this.searchStarted && !this.users && !this.showSpinner
  }

  get searchAvailable () {
    return !this.startDateTime || !this.endDateTime
  }

}
