import * as Elm from './Main';

import {userBridge} from "./js/user";


const app = Elm.Main.embed(document.getElementById('app'));

userBridge(app.ports);
