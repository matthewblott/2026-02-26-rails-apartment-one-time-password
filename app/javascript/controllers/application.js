import { Application } from "@hotwired/stimulus"
import { controllers } from "@joemasilotti/bridge-components"

const application = Application.start()
application.debug = false
window.Stimulus = application

application.load(controllers)

export { application }
