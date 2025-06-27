let discount = 0;
window.addEventListener("message", function (event) {
  var item = event.data;
  app.translate(item.translate)
  switch (item.action) {
    case "boss":
      app.openUI("boss", true);
      app.setupRanks(item.mechanic);
      app.setupMenu(item.mechanic);
      app.setupProfile(item.profile);
      app.addPlayerList(item.closestPlayers);
      break;
    case "tuning":
      app.openUI("tuning", true);
      app.setupNeons(item.neons);
      break;
    case "mechanic":
        app.openUI("mechanic", true);
        app.setupMechanic(item.mods);
        app.setupStatus(item.status, item.mechanic);
        discount = item.discount;
      break;
    case "craft":
      app.openUI("craft", true);
      app.setupCraft(item.craft);
      break;
    case "notification":
      app.showNotify(item.type, item.text);
      break;
    case "context":
      app.openContext(true, item.type);
      break;
    case "hideUI":
      app.hideUI(item.boolean);
      break;
  }
});

Vue.component('popup', {
  template: `
  <div class="pop-up-menu" v-show="popUpData.enabled">
      <div class="pop-inner">
          <div class="pop-up-text">
              <p> {{info.areyousure}} </p>
              <p v-show="popUpData.sell"> $9000 </p>
          </div>
          <div class="pop-up-button">
              <div class="accept-button" @click="confirm">
                  {{info.yes}}
              </div>
              <div class="decline-button" @click="cancel">
                  {{info.no}}
              </div>
          </div>
      </div>
  </div>
  `,
  props: ['info', 'popUpData'],
  methods: {
      confirm() {
          // Evet'e tıklandığında işlem sonucunu 'true' olarak ana bileşene iletiyoruz
          this.$emit('on-confirm', true);
      },
      cancel() {
          // Hayır'a tıklandığında işlem sonucunu 'false' olarak ana bileşene iletiyoruz
          this.$emit('on-cancel', false);
      },
  },
});

Coloris({
  el: ".coloris",
});

Coloris.setInstance(".instance1", {
  theme: "pill",
  themeMode: "dark",
  closeButton: true,
  clearButton: true,
  alpha: false,
  format: "rgb",
});

// Swatches kısmına olan far renklerini gir
Coloris.setInstance(".instance3", {
  theme: "polaroid",
  format: "rgb",
  themeMode: "dark",
  swatches: [
    "#264653",
    "#2a9d8f",
    "#e9c46a",
    "#f4a261",
    "#e76f51",
    "#d62828",
    "#023e8a",
    "#0077b6",
    "#0096c7",
    "#00b4d8",
    "#48cae4",
    "#90e0ef",
    "#ade8f4",
    "#caf0f8",
  ],
  swatchesOnly: true,
});

let circleProgress1;
let circleProgress2;
let circleProgress3;
let circleProgress4;
let firstCategory;
let firstMenu;
let currentIndex;
let newMechanic;
let currentMechanic;
let menuOpened;

function Status(circle1s, circle2s, circle3s, circle4s, type) {
  if (type == "install") {
      const circle1 = new ProgressBar.Circle('#circle-1', {
          color: '#000',
          strokeWidth: 10,
          trailColor: '#00000014',
          trailWidth: 10,
          duration: 2000, // milliseconds
          easing: 'easeInOut'
      });
      circleProgress1 = circle1
      ///////////////////////////////////
      const circle2 = new ProgressBar.Circle('#circle-2', {
          color: '#000',
          strokeWidth: 10,
          trailColor: '#00000014',
          trailWidth: 10,
          duration: 2000, // milliseconds
          easing: 'easeInOut'
      });
      circleProgress2 = circle2
      ///////////////////////////////////
      const circle3 = new ProgressBar.Circle('#circle-3', {
          color: '#000',
          strokeWidth: 10,
          trailColor: '#00000014',
          trailWidth: 10,
          duration: 2000, // milliseconds
          easing: 'easeInOut'
      });
      circleProgress3 = circle3
      ///////////////////////////////////
      const circle4 = new ProgressBar.Circle('#circle-4', {
          color: '#000',
          strokeWidth: 10,
          trailColor: '#00000014',
          trailWidth: 10,
          duration: 2000, // milliseconds
          easing: 'easeInOut'
      });
      circleProgress4 = circle4
      ///////////////////////////////////
      circleProgress1.animate(circle1s / 100)
      circleProgress2.animate(circle2s / 100)
      circleProgress3.animate(circle3s / 100)
      circleProgress4.animate(circle4s / 100)
  }
  if (type == "update") {
      circleProgress1.animate(circle1s / 100)
      circleProgress2.animate(circle2s / 100)
      circleProgress3.animate(circle3s / 100)
      circleProgress4.animate(circle4s / 100)
  }
}

const app = new Vue({
  el: "#app",
  data: {
    notifyText: {
      error: "Error!",
      success: "Success!",
      info: "Info!",
      hunger: "Yummy!",
      quest: "Quest!",
    },
    notifyDelay: 6000,

    bossMenu: {
      enabled: false,
      info: {
        dashboard: "Dashboard",
        settings: "Settings",
        employees: "Employees",
        managePerm: "Manage Permissions",
        managePermInfo: "Manage Permissions Info",
        employeeslist: "Employees List",
        addEmployee: "Add Employee",
        addnewemployee: "Add New Employee",
        addnewemployeedesc: "Add new employee to your mechanic",
        sellcompany: "Sell Company",
        totalassets: "Total Assets",
        totalemployees: "Total Employees",
        depositwithdraw: "DEPOSIT & WITHDRAW MONEYS",
        withdraw: "Withdraw Money",
        deposit: "Deposit Money",
        mechanicname: "Mechanic Name",
        setaname: "Set a name",
        mechanicdiscount: "Mechanic Discount",
        setdiscount: "Set a discount",
        vehiclecleaning: "wehicle clean & repair fee",
        updatefee: "Update Fee",
        areyousure: "Are you sure?",
        yes: "Yes",
        no: "No",
        history: "History",
        saveaname: "Save a name",
        savediscount: "Save discount",
        updateRank: "Update Rank",
        kickEmployee: "Kick Employee",
        applyChanges: "Apply Changes",
      },
      bossProfile: {
        img: "https://picsum.photos/300/300",
        name: "Ursu Arts",
        perm: 4,
      },
      ranks: [
        { name: "Boss", id: 4, sellCompany: true, withdraw: true, deposit: true,  addEmployee: true, updateDiscount: true, updateWashPrice: true, updateMechanicName: true, updateRank: true, kickEmployee: true, managePerm: true },
        { name: "Manager", id: 3, sellCompany: false, withdraw: true, deposit: true,  addEmployee: true, updateDiscount: true, updateWashPrice: true, updateMechanicName: true, updateRank: true, kickEmployee: true, managePerm: false },
        { name: "Mechanic", id: 332414215, sellCompany: false, withdraw: false, deposit: false,  addEmployee: false, updateDiscount: false, updateWashPrice: false, updateMechanicName: false, updateRank: false, kickEmployee: false, managePerm: false },
        { name: "Intern", id: 523432423, sellCompany: false, withdraw: false, deposit: false,  addEmployee: false, updateDiscount: false, updateWashPrice: false, updateMechanicName: false, updateRank: false, kickEmployee: false, managePerm: false },
      ],
      history: [],
      employeesList: [
        {
          name: "Test Dusa 1",
          img: "https://picsum.photos/300/300",
          rank: 3213,
          identifier: "31",
        },
        {
          name: "Test Dusa 2",
          img: "https://picsum.photos/300/300",
          rank: 12312,
          identifier: "32",
        },
        {
          name: "Test Dusa 3",
          img: "https://picsum.photos/300/300",
          rank: 34325213,
          identifier: "33",
        },
        {
          name: "Test Dusa 4",
          img: "https://picsum.photos/300/300",
          rank: 23423,
          identifier: "34",
        },
        {
          name: "Test Dusa 5",
          img: "https://picsum.photos/300/300",
          rank: 23123,
          identifier: "35",
        },
      ],
      playerList: [

      ],
      selectMenu: "dashboard",
      mechanicName: "Dusa Mechanic",
      newMechanicName: "",
      discount: 30,
      newDiscount: null,
      washPrice: 100,
      newWashPrice: null,
      totalMoney: 0,
      totalEmployees: 5,
      depositMoney: 0,
      popUpData: {
        enabled: false,
        action: "",
        sell: false,
        identifier: null,
        name: null,
        mechanicPrice: 9000,
      },
      addEmployee: false,
    },
    mechanicMenu: {
      enabled: false,
      info: {
        enter: "Enter",
        buy: "Buy",
        buyed: "Buyed",
        circle1: "Circle 1",
        circle2: "Circle 2",
        circle3: "Circle 3",
        circle4: "Circle 4",
        washCar: "Wash Car",
        fixCar: "Fix Car",
        colorTitle: "Color Settings",
        primaryColor: "Primary Color",
        secondaryColor: "Secondary Color",
        classic: "Classic",
        metallic: "Metallic",
        matte: "Matte",
        metal: "Metal",
        chrome: "Chrome",
        pearlescent: "Pearlescent",
        card: "Card",
        delete: "Delete",
        total: "Total",
        paycash: "Pay Cash",
        paycard: "Pay Card",
        clearCard: "Clear Card",
        addCard: "Add Card",
        close: "Close",
        color: "Color",
        deleteCard: "Delete Card",
        notenoughmoney: "You dont have enough money",
        payfromcompany: "Pay from company",
      },
      categories: [
        {
          name: "Engine",
          img: "assets/img/icon/engine.png",
          modId: "plates",
          type: "category",
        },
        {
          name: "Engine",
          img: "assets/img/icon/engine.png",
          modId: "plates",
          type: "category",
        },
        {
          name: "Engine",
          img: "assets/img/icon/engine.png",
          modId: "plates",
          type: "category",
        },
        {
          modId: "buffer",
          img: "assets/img/icon/engine.png",
          name: "Front Bumper",
          mod: 4,
          price: 1000,
          type: "item",
        },
        {
          name: "Engine",
          img: "assets/img/icon/engine.png",
          modId: "plates",
          type: "category",
        },
        {
          name: "Engine",
          img: "assets/img/icon/engine.png",
          modId: "plates",
          type: "category",
        },
        {
          modId: "buffer",
          img: "assets/img/icon/engine.png",
          name: "Front Bumper",
          mod: 3,
          price: 1000,
          type: "item",
        },
        {
          name: "Engine",
          img: "assets/img/icon/engine.png",
          modId: "plates",
          type: "category",
        },
        {
          modId: "buffer",
          img: "assets/img/icon/engine.png",
          name: "Front Bumper",
          mod: 6,
          price: 1000,
          type: "item",
        },
      ],
      card: [],
      cachedParts: [],
      // Kategori içine girince true
      showItems: false,
      itemsImage: null,
      activeIndex: 0,
      wheelColor: [
          { name: "Black", colorindex: 0, hex: "#0d1116" },
          { name: "Carbon Black", colorindex: 147, hex: "#11141a"},
          { name: "Hraphite", colorindex: 1, hex: "#1c1d21" },
          { name: "Anhracite Black", colorindex: 11, hex: "#1d2129" },
          { name: "Black Steel", colorindex: 2, hex: "#32383d" },
          { name: "Dark Steel", colorindex: 3, hex: "#454b4f" },
          { name: "Silver", colorindex: 4, hex: "#999da0" },
          { name: "Bluish Silver", colorindex: 5, hex: "#c2c4c6" },
          { name: "Rolled Steel", colorindex: 6, hex: "#979a97" },
          { name: "Shadow Silver", colorindex: 7, hex: "#637380" },
          { name: "Stone Silver", colorindex: 8, hex: "#63625c" },
          { name: "Midnight Silver", colorindex: 9, hex: "#3c3f47" },
          { name: "Cast Iron Silver", colorindex: 10, hex: "#444e54" },
          { name: "Red", colorindex: 27, hex: "#c00e1a" },
          { name: "Torino Red", colorindex: 28, hex: "#da1918" },
          { name: "Formula Red", colorindex: 29, hex: "#b6111b" },
          { name: "Lava Red", colorindex: 150, hex: "#bc1917" },
          { name: "Blaze Red", colorindex: 30, hex: "#a51e23" },
          { name: "Grace Red", colorindex: 31, hex: "#7b1a22" },
          { name: "Garnet Red", colorindex: 32, hex: "#8e1b1f" },
          { name: "Sunset Red", colorindex: 33, hex: "#6f1818" },
          { name: "Cabernet Red", colorindex: 34, hex: "#49111d" },
          { name: "Wine Red", colorindex: 143, hex: "#0e0d14" },
          { name: "Candy Red", colorindex: 35, hex: "#b60f25" },
          { name: "Hot Pink", colorindex: 135, hex: "#f21f99" },
          { name: "Pfsiter Pink", colorindex: 137, hex: "#df5891" },
          { name: "Salmon Pink", colorindex: 136, hex: "#fdd6cd" },
          { name: "Sunrise Orange", colorindex: 36, hex: "#d44a17" },
          { name: "Orange", colorindex: 38, hex: "#f78616" },
          { name: "Bright Orange", colorindex: 138, hex: "#f6ae20" },
          { name: "Gold", colorindex: 99, hex: "#ac9975" },
          { name: "Bronze", colorindex: 90, hex: "#916532" },
          { name: "Yellow", colorindex: 88, hex: "#ffcf20" },
          { name: "Race Yellow", colorindex: 89, hex: "#fbe212" },
          { name: "Dew Yellow", colorindex: 91, hex: "#e0e13d" },
          { name: "Dark Green", colorindex: 49, hex: "#132428" },
          { name: "Racing Green", colorindex: 50, hex: "#122e2b" },
          { name: "Sea Green", colorindex: 51, hex: "#12383c" },
          { name: "Olive Green", colorindex: 52, hex: "#31423f" },
          { name: "Bright Green", colorindex: 53, hex: "#155c2d" },
          { name: "Gasoline Green", colorindex: 54, hex: "#1b6770" },
          { name: "Lime Green", colorindex: 92, hex: "#98d223" },
          { name: "Midnight Blue", colorindex: 141, hex: "#0a0c17" },
          { name: "Galaxy Blue", colorindex: 61, hex: "#222e46" },
          { name: "Dark Blue", colorindex: 62, hex: "#233155" },
          { name: "Saxon Blue", colorindex: 63, hex: "#304c7e" },
          { name: "Blue", colorindex: 64, hex: "#47578f" },
          { name: "Mariner Blue", colorindex: 65, hex: "#637ba7" },
          { name: "Harbor Blue", colorindex: 66, hex: "#394762" },
          { name: "Diamond Blue", colorindex: 67, hex: "#d6e7f1" },
          { name: "Surf Blue", colorindex: 68, hex: "#76afbe" },
          { name: "Nautical Blue", colorindex: 69, hex: "#345e72" },
          { name: "Racing Blue", colorindex: 73, hex: "#2354a1" },
          { name: "Ultra Blue", colorindex: 70, hex: "#0b9cf1" },
          { name: "Light Blue", colorindex: 74, hex: "#6ea3c6" },
          { name: "Chocolate Brown", colorindex: 96, hex: "#221b19" },
          { name: "Bison Brown", colorindex: 101, hex: "#402e2b" },
          { name: "Creeen Brown", colorindex: 95, hex: "#473f2b" },
          { name: "Feltzer Brown", colorindex: 94, hex: "#503218" },
          { name: "Maple Brown", colorindex: 97, hex: "#653f23" },
          { name: "Beechwood Brown", colorindex: 103, hex: "#46231a" },
          { name: "Sienna Brown", colorindex: 104, hex: "#752b19" },
          { name: "Saddle Brown", colorindex: 98, hex: "#775c3e" },
          { name: "Moss Brown", colorindex: 100, hex: "#6c6b4b" },
          { name: "Woodbeech Brown", colorindex: 102, hex: "#a4965f" },
          { name: "Straw Brown", colorindex: 99, hex: "#ac9975" },
          { name: "Sandy Brown", colorindex: 105, hex: "#bfae7b" },
          { name: "Bleached Brown", colorindex: 106, hex: "#dfd5b2" },
          { name: "Schafter Purple", colorindex: 71, hex: "#2f2d52" },
          { name: "Spinnaker Purple", colorindex: 72, hex: "#282c4d" },
          { name: "Midnight Purple", colorindex: 142, hex: "#0c0d18" },
          { name: "Bright Purple", colorindex: 145, hex: "#621276" },
          { name: "Cream", colorindex: 107, hex: "#f7edd5" },
          { name: "Ice White", colorindex: 111, hex: "#fffff6" },
          { name: "Frost White", colorindex: 112, hex: "#eaeaea" },
      ],
      carColor: [
          { name: "Primary", color: "rgb(255, 255, 255)", type: "Classic" },
          { name: "Secondary", color: "rgb(255, 255, 255)", type: "Classic" },
          { name: "Wheel", color: null, },
      ],
      carColorMenu: [
          { name: "Primary", category: "primary" },
          { name: "Secondary", category: "secondary" },
          { name: "Wheel", category: "wheel" },
      ],
      activeColor: 0,
      carColorType1: [
          { name: "Classic", type: "Classic" },
          { name: "Metallic", type: "Metallic" },
          { name: "Matte", type: "Matte" },
          { name: "Metal", type: "Metal" },
          { name: "Chrome", type: "Chrome" },
          { name: "Pearlescent", type: "Pearlescent" },
      ],
      type1: 0,
      carColorType2: [
          { name: "Classic", type: "Classic" },
          { name: "Metallic", type: "Metallic" },
          { name: "Matte", type: "Matte" },
          { name: "Metal", type: "Metal" },
          { name: "Chrome", type: "Chrome" },
          { name: "Pearlescent", type: "Pearlescent" },
      ],
      type2: 0,
      status: {
          circle1: 60,
          circle2: 80,
          circle3: 10,
          circle4: 20,
      },
      panelView: true,
      washPrice: 999,
      fixPrice: 999,
      carModel: "Car Model",
      colorMenu: false,
      colorPrice: 1000,
      cardOpen: false,
    },
    fitMenu: {
      enabled: false,
      info: {
        fitMenu: "Fit Menu",
        wheelsWidth: "Wheels Width",
        wheelsFrontLeft: "Wheels Front Left",
        wheelsFrontRight: "Wheels Front Right",
        wheelsRearLeft: "Wheels Rear Left",
        wheelsRearRight: "Wheels Rear Right",
        wheelsFrontCamberLeft: "Wheels Front Camber Left",
        wheelsFrontCamberRight: "Wheels Front Camber Right",
        wheelsRearCamberLeft: "Wheels Rear Camber Left",
        wheelsRearCamberRight: "Wheels Rear Camber Right",
        applySettings: "Apply Settings",
      },
      fitMenu: [
        {type: "wheelsWidth", value: 0},
        {type: "wheelsFrontLeft", value: 0},
        {type: "wheelsFrontRight", value: 0},
        {type: "wheelsRearLeft", value: 0},
        {type: "wheelsRearRight", value: 0},
        {type: "wheelsFrontCamberLeft", value: 0},
        {type: "wheelsFrontCamberRight", value: 0},
        {type: "wheelsRearCamberLeft", value: 0},
        {type: "wheelsRearCamberRight", value: 0},
      ]
    },
    tuningMenu: {
      enabled: false,
      info: {
        tuningtitle: "Dusa Tuning",
        tuninginfo: "Tune your vehicle",
        mods: "Mods",
        detail: "Details",
        neon: "Neon",
        headlights: "Headlights",
        select: "Select",
        selected: "Selected",
        applySettings: "Apply Settings",
        cancel: "Cancel",
        boost: "Boost",
        acceleration: "Acceleration",
        breaking: "Breaking",
        gearchange: "Gear Change",
        drivetrain: "Drivetrain",
        front: "Front",
        back: "Back",
        left: "Left",
        right: "Right",
        rainbow: "Rainbow",
        default: "Default",
        snake: "Snake",
        crisscross: "Criss Cross",
        lightnings: "Lightning",
        fourways: "Four Ways",
        blinking: "Blinking",
        customDusa: "Custom Dusa",
      },
      mods: [
        {
          name: "Sport Mode",
          selected: false,
          img: "assets/img/tuning/engine-mods.png",
          type: "sport",
        },
        {
          name: "Drift Mode",
          selected: false,
          img: "assets/img/tuning/engine-mods.png",
          type: "drift",
        },
        {
          name: "Eco Mode",
          selected: false,
          img: "assets/img/tuning/engine-mods.png",
          type: "eco",
        },
      ],
      // Bunları 100 e böl 0.5 falan elde edersin
      details: {
        boost: 50,
        acceleration: 50,
        breaking: 50,
        gearchange: 50,
        drivetrain: 50,
      },
      detailsNew: {
        boost: null,
        acceleration: null,
        breaking: null,
        gearchange: null,
        drivetrain: null,
      },
      neonColor: 'rgb(255, 255, 255)',
      neon: {
          front: false,
          back: false,
          left: false,
          right: false,
      },
      newNeonColor: null,
      newNeon: {
          front: false,
          back: false,
          left: false,
          right: false,
          snake: false,
          crisscross: false,
          lightnings: false,
          fourways: false,
          blinking: false,
          customDusa: false,
      },
      rainbowNeon: false,
      rainbowHeadlights: false,
      headlights: "rgb(255, 255, 255)",
      newHeadlights: null,
      selectMode: 0,
      newSelectMode: null,
      selectMenu: 'mods',
    },
    craftMenu:{
      enabled: false,
      info:{
          craft: "CRAFTING",
          bench: "BENCH",
          youritems: "YOUR ITEMS",
          craftdesc: "Craft best equipments for yourself!",
          needItems: "NEED ITEMS",
          craftItem: "CRAFT!",
      },
      items: [
          { name: "Craft Item 1", img: "assets/img/tuning/engine-mods.png", required:[
              { name: "Item 1", count: 5, owned: 5 },
              { name: "Item 2", count: 5, owned: 5 },
              { name: "Item 3", count: 5, owned: 5 },
              { name: "Item 4", count: 5, owned: 5 },
          ] },
          { name: "Craft Item 2", img: "assets/img/tuning/engine-mods.png", required:[
              { name: "Item 1", count: 5, owned: 0 },
              { name: "Item 2", count: 5, owned: 5 },
              { name: "Item 3", count: 5, owned: 4 },
              { name: "Item 4", count: 5, owned: 5 },
          ] },
          { name: "Craft Item 3", img: "assets/img/tuning/engine-mods.png", required:[
              { name: "Item 1", count: 5, owned: 5 },
              { name: "Item 2", count: 5, owned: 5 },
              { name: "Item 3", count: 5, owned: 5 },
              { name: "Item 4", count: 5, owned: 5 },
          ] },
          { name: "Craft Item 4", img: "assets/img/tuning/engine-mods.png", required:[
              { name: "Item 1", count: 5, owned: 0 },
              { name: "Item 2", count: 5, owned: 5 },
              { name: "Item 3", count: 5, owned: 4 },
              { name: "Item 4", count: 5, owned: 5 },
          ] },
          { name: "Craft Item 5", img: "assets/img/tuning/engine-mods.png", required:[
              { name: "Item 1", count: 5, owned: 0 },
              { name: "Item 2", count: 5, owned: 5 },
              { name: "Item 3", count: 5, owned: 4 },
              { name: "Item 4", count: 5, owned: 5 },
          ] },
          { name: "Craft Item 6", img: "assets/img/tuning/engine-mods.png", required:[
              { name: "Item 1", count: 5, owned: 0 },
              { name: "Item 2", count: 5, owned: 5 },
              { name: "Item 3", count: 5, owned: 4 },
              { name: "Item 4", count: 5, owned: 5 },
          ] },
      ],
    },
    liftControl:{
        enabled: false,
        info:{
            up: "Up",
            stop: "Stop",
            down: "Down",
            title: "Lift Control",
            liftdesc: "Manage car lift for vehicles",
            detachVehicle: "Detach Vehicle",
        },
        up: false,
        down: false,
        stop: false,
        detachVehicle: false,
    },
    liftControl2:{
      enabled: false,
      info:{
          sabit: "Attach",
          sabitcikar: "Detach",
          rampayiindir: "Toggle Ramp",
          title: "Lift Control",
          towdesc: "Transport a vehicle with flatbed!",
          detachVehicle: "Detach Vehicle",
      },
      sabit: false,
      sabitcikar: false,
      rampayiindir: false,
    }
  },
  mounted() {
    // this.addPlayerList();

    // Her tuning tablet açıldığında yaptırılacaklar
    let findMode = this.tuningMenu.mods.findIndex((x) => x.type == this.tuningMenu.selectMode);
    if (findMode == -1 || findMode == undefined || findMode == null) {
      // this.tuningMenu.mods[0].selected = true;
      // this.tuningMenu.selectMode = this.tuningMenu.mods[0].type;
    } else {
      this.tuningMenu.mods[findMode].selected = true;
      this.tuningMenu.selectMode = this.tuningMenu.mods[findMode];
    }
    this.tuningMenu.detailsNew = this.tuningMenu.details;
    this.tuningMenu.newNeonColor = this.tuningMenu.neonColor;
    this.tuningMenu.newNeon = this.tuningMenu.neon;
    this.tuningMenu.newHeadlights = this.tuningMenu.headlights;
    this.tuningMenu.newSelectMode = this.tuningMenu.selectMode;

    // Status kurulum
    Status(this.mechanicMenu.status.circle1, this.mechanicMenu.status.circle2, this.mechanicMenu.status.circle3, this.mechanicMenu.status.circle4, "install");

    var colorPicker = new iro.ColorPicker("#picker", {
        width: window.innerWidth / 9.8,
        borderWidth: 2,
        borderColor: "#fff",
        margin: 30,
        // Set the size of the color picker
        // Set the initial color to pure red
        color: this.mechanicMenu.carColor[0].color,
    });
    var colorPicker2 = new iro.ColorPicker("#picker2", {
        width: window.innerWidth / 9.8,
        borderWidth: 2,
        borderColor: "#fff",
        margin: 30,
        // Set the size of the color picker
        // Set the initial color to pure red
        color: this.mechanicMenu.carColor[0].color,
    });
    var colorPicker3 = new iro.ColorPicker("#picker3", {
        width: window.innerWidth / 10,
        borderWidth: 2,
        borderColor: "#fff",
        margin: 30,
        // Set the size of the color picker
        // Set the initial color to pure red
        color: this.tuningMenu.newNeonColor,
    });

    var colorPicker4 = new iro.ColorPicker("#picker4", {
      width: window.innerWidth / 10,
      borderWidth: 2,
      borderColor: "#fff",
      margin: 30,
      // Set the size of the color picker
      // Set the initial color to pure red
      color: this.tuningMenu.headlights,
    });

    let self = this;
    colorPicker.on('color:change', function (colors) {
        self.mechanicMenu.carColor[0].color = colors.rgbString;
        post('hoverModel', {modId: 'color1', mod: self.mechanicMenu.carColor[0].color})
    });
    colorPicker2.on('color:change', function (colors) {
        self.mechanicMenu.carColor[1].color = colors.rgbString;
        post('hoverModel', {modId: 'color2', mod: self.mechanicMenu.carColor[1].color})
    });
    colorPicker3.on('color:change', function (colors) {
        self.tuningMenu.newNeonColor = colors.rgbString;
    });
    colorPicker4.on('color:change', function (colors) {
      self.tuningMenu.newHeadlights = colors.rgbString;
    });
  },
  computed: {
    totalMoney: function () {
      const formatter = new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: "USD",
      });
      return formatter.format(this.bossMenu.totalMoney);
    },
    totalemployees: function () {
      return this.bossMenu.employeesList.length;
    },
    cardTotal: function () {
      const formatter = new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: "USD",
      });
      let total = 0;
      this.mechanicMenu.card.forEach((element) => {
        total += element.price;
      });
      return formatter.format(total);
    },
    cardTotalDiscount: function () {
      const formatter = new Intl.NumberFormat('en-US', {
          style: 'currency',
          currency: 'USD',
      });
      let total = 0;
      this.mechanicMenu.card.forEach(element => {
          total += element.price;
      });
      return formatter.format(total - (total * (this.bossMenu.discount / 100)));
  },
  },
  methods: {
    showNotify(type, notify) {
      this.notify(type, notify);
    },
    openUI(ui, bool) {
      if (ui === "boss") {
        if (!bool) {
          this.bossMenu.enabled = false;
        } else {
          this.bossMenu.enabled = true;
        }
      } else if (ui === "tuning") {
        if (!bool) {
          this.tuningMenu.enabled = false;
        } else {
          this.tuningMenu.enabled = true;
        }
      } else if (ui === "craft") {
        if (!bool) {
          this.craftMenu.items = [];
          this.craftMenu.enabled = false;
        } else {
          this.craftMenu.enabled = true;
        }
      } else if (ui === "mechanic") {
        if (!bool) {
          this.mechanicMenu.enabled = false;
          menuOpened = false;
        } else {
          this.mechanicMenu.enabled = true;
          menuOpened = true;
          this.post('rotateCamera', {menu: "menu", objectId: 0, component: false})
        }
      }
    },
    openContext(bool, type) {
      if (type === "lift") {
        if (!bool) { this.liftControl.enabled = false; } else {
          this.liftControl.enabled = true;
        }
      } else if (type === "flatbed") {
        if (!bool) { this.liftControl2.enabled = false; } else {
          this.liftControl2.enabled = true;
        }
      }
    },
    // Boss Menu
    setupMenu(mechanic) {
      // HISTORY
      // SELL COMPANY
      // FONKSIYONLAR (OYUNCU KICKLEME, ALMA, RÜTBE DÜŞÜRME ARTIRMA)
      var md = JSON.parse(mechanic.mechanic);
      let employees;
      try {
        employees = JSON.parse(mechanic.employees);
      } catch (error) {
        employees = JSON.parse(JSON.stringify(mechanic.employees)); // Hata oluştuğunda string olarak devam et
      }
      var boss = JSON.parse(mechanic.boss);
      this.bossMenu.mechanicName = md.name;
      this.bossMenu.totalMoney = md.vault;
      this.bossMenu.discount = md.discount;
      this.bossMenu.washPrice = md.fee;
      this.bossMenu.employeesList = [];
      employees.forEach((e) => {
        this.bossMenu.employeesList.push({
          name: e.name,
          identifier: e.identifier,
          rank: e.rank,
          img: e.img,
        });
      });
    },
    setupMechanic(data) {
      this.mechanicMenu.categories = [];
      firstCategory = data;
      firstMenu;
      data.forEach((e) => {
        this.mechanicMenu.categories.push({
          name: e.label,
          category: e.category,
          img: "assets/img/icon/" + e.img + ".png",
          items: e.items,
          type: "category",
        });
      });
    },
    setupRanks(data) {
      this.bossMenu.ranks = [];
      var ranks = JSON.parse(data.ranks);      
      const sortedRanks = ranks.sort((a, b) => a.id - b.id);

      const newRanks = sortedRanks.map((e) => ({
        name: e.name,
        id: e.id,
        withdraw: e.withdraw,
        deposit: e.deposit,
        addEmployee: e.addEmployee,
        updateDiscount: e.updateDiscount,
        updateWashPrice: e.updateWashPrice,
        updateMechanicName: e.updateMechanicName,
        updateRank: e.updateRank,
        kickEmployee: e.kickEmployee,
        managePerm: e.managePerm,
      }));
      this.bossMenu.ranks = newRanks;
    },
    setupProfile(data) {
      this.bossMenu.bossProfile.name = data.name;
      this.bossMenu.bossProfile.perm = data.rank;
    },
    setupCraft(data) {
      this.craftMenu.items = [];
      data.forEach(e => {
        this.craftMenu.items.push({
          name: e.name, 
          img: e.img || "assets/img/tuning/engine-mods.png",
          item: e.item,
          required: e.requirements,
          prop: e.prop,
          selected: false
        })
      })
    },
    setupNeons(neon) {
      if (neon) {
        // this.tuningMenu.details.boost = neon.boost
        // this.tuningMenu.details.acceleration = neon.acceleration
        // this.tuningMenu.details.breaking = neon.breaking
        // this.tuningMenu.details.gearchange = neon.gearchange
        // this.tuningMenu.details.drivetrain = neon.drivetrain
        this.tuningMenu.headlights = neon.headlights
        this.tuningMenu.neonColor = neon.neoncolor
        this.tuningMenu.neon.front = neon.front_neon
        this.tuningMenu.neon.back = neon.back_neon
        this.tuningMenu.neon.left = neon.left_neon
        this.tuningMenu.neon.right = neon.right_neon
        this.tuningMenu.selectMode = neon.vehiclemode
      }
    },
    handleConfirm(result) {
      if (this.bossMenu.popUpData.action == "sellCompany") {
      } else if (this.bossMenu.popUpData.action == "kickEmployee") {
        let index = this.bossMenu.employeesList.findIndex(
          (x) => x.identifier == this.bossMenu.popUpData.identifier
        );
        this.bossMenu.employeesList.splice(index, 1);
        this.post("kickStaff", { staff: this.bossMenu.popUpData });
        this.bossMenu.popUpData.identifier = null;
      }
      this.bossMenu.popUpData.action = "";
      this.bossMenu.popUpData.sell = false;
      this.bossMenu.popUpData.identifier = null;
      this.bossMenu.popUpData.name = null;
      this.bossMenu.popUpData.enabled = false;
    },
    handleCancel(result) {
      this.bossMenu.popUpData.action = "";
      this.bossMenu.popUpData.sell = false;
      this.bossMenu.popUpData.identifier = null;
      this.bossMenu.popUpData.name = null;
      this.bossMenu.popUpData.enabled = false;
    },
    sellCompany() {
      this.bossMenu.popUpData.action = "sellCompany";
      this.bossMenu.popUpData.sell = true;
      this.bossMenu.popUpData.enabled = true;
    },
    deposit() {
      if (this.bossMenu.depositMoney < 0) {
        return;
      } else if (this.bossMenu.depositMoney == 0) {
        return;
      } else {
        let money = Number(this.bossMenu.depositMoney);
        if (money == NaN) {
          return;
        } else {
          fetch(`https://dusa_mechanic/checkBossMoney`, {
            method: "POST",
          headers: {
            "Content-Type": "application/json; charset=UTF-8",
          },
          body: JSON.stringify({
            amount: money,
            type: 'cash'
          }),
        })
          .then((hasMoney) => hasMoney.json())
          .then((hasMoney) => {
            if (hasMoney === false) {
              this.post('notEnoughMoney')
              return;
            }
            this.bossMenu.history.unshift({
              name: this.bossMenu.bossProfile.name,
              price: this.bossMenu.depositMoney,
              img: this.bossMenu.bossProfile.img,
            });
            this.bossMenu.totalMoney += money;
            this.post("deposit", { amount: money });
            this.bossMenu.depositMoney = 0;
          });
        }
      }
    },
    withdraw() {
      if (this.bossMenu.depositMoney > this.bossMenu.totalMoney) {
        this.post('notEnoughMoney')
        return;
      } else if (this.bossMenu.depositMoney < 0) {
        return;
      } else if (this.bossMenu.depositMoney == 0) {
        return;
      } else {
        this.bossMenu.history.unshift({
          name: this.bossMenu.bossProfile.name,
          price: -1 * this.bossMenu.depositMoney,
          img: this.bossMenu.bossProfile.img,
        });
        this.bossMenu.totalMoney -= this.bossMenu.depositMoney;
        this.post("withdraw", { amount: this.bossMenu.depositMoney });
        this.bossMenu.depositMoney = 0;
      }
    },
    kickEmployee(identifier) {
      this.bossMenu.popUpData.action = "kickEmployee";
      this.bossMenu.popUpData.identifier = identifier;
      this.bossMenu.popUpData.enabled = true;
    },
    changeName() {
      if (this.bossMenu.newMechanicName.length > 3) {
        this.bossMenu.mechanicName = this.bossMenu.newMechanicName;
        this.post("setName", { name: this.bossMenu.newMechanicName });
        this.bossMenu.newMechanicName = "";
      }
    },
    changeDiscount() {
      if (this.bossMenu.newDiscount > 0 && this.bossMenu.newDiscount <= 100) {
        this.bossMenu.discount = this.bossMenu.newDiscount;
        this.post("setDiscount", { discount: this.bossMenu.newDiscount });
        this.bossMenu.newDiscount = null;
      } else {
        this.bossMenu.newDiscount = null;
      }
    },
    changeWashPrice() {
      if (this.bossMenu.newWashPrice > 0) {
        this.bossMenu.washPrice = this.bossMenu.newWashPrice;
        this.post("setFee", { fee: this.bossMenu.newWashPrice });
        this.bossMenu.newWashPrice = null;
      } else {
        this.bossMenu.newWashPrice = null;
      }
    },
    getRank: function (rank) {
      let findRank = this.bossMenu.ranks.findIndex((x) => x.id == rank);
      if (findRank == -1 || findRank == undefined || findRank == null) {
        return "Unknown";
      } else return this.bossMenu.ranks[findRank].name;
    },
    downRank: function (item) {
      let findRank = this.bossMenu.ranks.findIndex((x) => x.id == item.rank);
      if (findRank == -1 || findRank == undefined || findRank == null || findRank == 0) {
        return;
      }
      if (findRank == this.bossMenu.ranks.length - 1) {
        return;
      } else {
        item.rank = this.bossMenu.ranks[findRank - 1].id;
        this.post("demote", item);
      }
    },
    upRank: function (item) {
      let findRank = this.bossMenu.ranks.findIndex((x) => x.id == item.rank);
      let maxIndex = this.bossMenu.ranks.reduce((maxIndex, current, currentIndex) => {
        return current.id > this.bossMenu.ranks[maxIndex].id ? currentIndex : maxIndex;
      }, 0);
      if (findRank == -1 || findRank == undefined || findRank == null || findRank >= this.bossMenu.ranks[maxIndex].id) {
        return;
      }
      item.rank = this.bossMenu.ranks[findRank + 1].id;
      this.post("promote", item);
    },
    addEmployee: function (item) {
      // İtem delete player list
      let index = this.bossMenu.playerList.findIndex(
        (x) => x.identifier == item.identifier
      );
      this.bossMenu.playerList.splice(index, 1);
      // İtem add employee list
      // { name: "Boss", id: 3213, sellCompany: true, withdraw: true, deposit: true,  addEmployee: true, updateDiscount: true, updateWashPrice: true, updateMechanicName: true, updateRank: true, kickEmployee: true, managePerm: true },
      this.bossMenu.employeesList.push({
        name: item.name,
        img: item.img,
        rank: this.bossMenu.ranks[this.bossMenu.ranks.length - 1].id,
        identifier: item.identifier,
      });
      this.post("addEmployee", item);
    },
    addPlayerList: function (data) {
      this.bossMenu.playerList = [];
      data.forEach(element => {
        let index = this.bossMenu.employeesList.findIndex(x => x.identifier == element.identifier);
        if (index == -1) {
          this.bossMenu.playerList.push(element);
        }
      });
    },
    checkPerm: function (item, perm) {
      let findRank = this.bossMenu.ranks.findIndex(x => x.id == item); // 0 1 2 3 4 5
      if (findRank == -1 || findRank == undefined || findRank == null) {
          return false;
      }
      else {
          return this.bossMenu.ranks[findRank][perm];
      }
    },
    applyRanks: function () {
      this.post('applyRanks', this.bossMenu.ranks)
      this.showNotify('Ranks updated successfully!', 'success')
    },

    //Tuning
    modsSelect: function (item) {
      if(item.selected){
          item.selected = false;
          this.tuningMenu.newSelectMode = null;
          this.tuningMenu.mods.forEach(element => {
              element.selected = false;
          });
          return;
      }else{
          this.tuningMenu.mods.forEach(element => {
              element.selected = false;
          });
          item.selected = true;
          this.tuningMenu.newSelectMode = item.type;
      }
    },
    applySettings: function () {
      var tuning = {};
      tuning.boost = this.tuningMenu.details.boost;
      tuning.acceleration = this.tuningMenu.details.acceleration;
      tuning.breaking = this.tuningMenu.details.breaking;
      tuning.gearchange = this.tuningMenu.details.gearchange;
      tuning.drivetrain = this.tuningMenu.details.drivetrain;
      tuning.headlights = this.tuningMenu.headlights;
      tuning.neoncolor = this.tuningMenu.neonColor;
      tuning.front_neon = this.tuningMenu.neon.front;
      tuning.back_neon = this.tuningMenu.neon.back;
      tuning.left_neon = this.tuningMenu.neon.left;
      tuning.right_neon = this.tuningMenu.neon.right;
      tuning.vehiclemode = this.tuningMenu.selectMode;

      tuning.neonrgb = this.tuningMenu.rainbowNeon
      tuning.headlightsrgb = this.tuningMenu.rainbowHeadlights

      tuning.anims = this.tuningMenu.newNeon

      if (this.tuningMenu.newSelectMode != null) {
        this.tuningMenu.selectMode = this.tuningMenu.newSelectMode;
        tuning.vehiclemode = this.tuningMenu.selectMode;
        // this.tuningMenu.newSelectMode = null;
      }
      if (this.tuningMenu.detailsNew.boost != null) {
        this.tuningMenu.details.boost = this.tuningMenu.detailsNew.boost;
        tuning.boost = this.tuningMenu.detailsNew.boost;
        // this.tuningMenu.detailsNew.boost = null;
      }
      if (this.tuningMenu.detailsNew.acceleration != null) {
        this.tuningMenu.details.acceleration =
          this.tuningMenu.detailsNew.acceleration;
        tuning.acceleration = this.tuningMenu.detailsNew.acceleration;
        // this.tuningMenu.detailsNew.acceleration = null;
      }
      if (this.tuningMenu.detailsNew.breaking != null) {
        this.tuningMenu.details.breaking = this.tuningMenu.detailsNew.breaking;
        tuning.breaking = this.tuningMenu.detailsNew.breaking;
        // this.tuningMenu.detailsNew.breaking = null;
      }
      if (this.tuningMenu.detailsNew.gearchange != null) {
        this.tuningMenu.details.gearchange =
          this.tuningMenu.detailsNew.gearchange;
        tuning.gearchange = this.tuningMenu.detailsNew.gearchange;
        // this.tuningMenu.detailsNew.gearchange = null;
      }
      if (this.tuningMenu.detailsNew.drivetrain != null) {
        this.tuningMenu.details.drivetrain =
          this.tuningMenu.detailsNew.drivetrain;
        tuning.drivetrain = this.tuningMenu.detailsNew.drivetrain;
        // this.tuningMenu.detailsNew.drivetrain = null;
      }

      if (this.tuningMenu.newNeonColor != null) {
        this.tuningMenu.neonColor = this.tuningMenu.newNeonColor;
        tuning.neoncolor = this.tuningMenu.neonColor;
        // this.tuningMenu.newNeonColor = null;
      }
      if (this.tuningMenu.newHeadlights != null) {
        this.tuningMenu.headlights = this.tuningMenu.newHeadlights;
        tuning.headlights = this.tuningMenu.headlights;
        // this.tuningMenu.newHeadlights = null;
      }
      if (this.tuningMenu.newNeon.front != null) {
        this.tuningMenu.neon.front = this.tuningMenu.newNeon.front;
        tuning.front_neon = this.tuningMenu.neon.front;
        // this.tuningMenu.newNeon.front = null;
      }
      if (this.tuningMenu.newNeon.back != null) {
        this.tuningMenu.neon.back = this.tuningMenu.newNeon.back;
        tuning.back_neon = this.tuningMenu.neon.back;
        // this.tuningMenu.newNeon.back = null;
      }
      if (this.tuningMenu.newNeon.left != null) {
        this.tuningMenu.neon.left = this.tuningMenu.newNeon.left;
        tuning.left_neon = this.tuningMenu.neon.left;
        // this.tuningMenu.newNeon.left = null;
      }
      if (this.tuningMenu.newNeon.right != null) {
        this.tuningMenu.neon.right = this.tuningMenu.newNeon.right;
        tuning.right_neon = this.tuningMenu.neon.right;
        // this.tuningMenu.newNeon.right = null;
      }
      this.post("applyTuning", tuning);
    },
    cancelSettings: function () {
      this.tuningMenu.newSelectMode = null;
      this.tuningMenu.detailsNew.boost = 50;
      this.tuningMenu.detailsNew.acceleration = 50;
      this.tuningMenu.detailsNew.breaking = 50;
      this.tuningMenu.detailsNew.gearchange = 50;
      this.tuningMenu.detailsNew.drivetrain = 50;
      this.tuningMenu.newNeonColor = null;
      this.tuningMenu.newNeon = this.tuningMenu.neon;
      this.tuningMenu.newHeadlights = null;
    },

    // Mechanic Menu
    setupStatus: function(status, data) {
      data = JSON.parse(data.mechanic)
      this.mechanicMenu.info.circle1 = status[1].label
      this.mechanicMenu.status.circle1 = status[1].value.toFixed(0)
      this.mechanicMenu.info.circle2 = status[2].label
      this.mechanicMenu.status.circle2 = status[2].value.toFixed(0)
      this.mechanicMenu.info.circle3 = status[3].label
      this.mechanicMenu.status.circle3 = status[3].value.toFixed(0)
      this.mechanicMenu.info.circle4 = status[0].label
      this.mechanicMenu.status.circle4 = status[0].value.toFixed(0)
      this.mechanicMenu.carModel = status[4].name
      this.mechanicMenu.washPrice = data.fee
      this.mechanicMenu.fixPrice = data.fee
    },

    mechanicRotate: function (event) {
      if (!this.mechanicMenu.enabled) return;
      if (event.key === "ArrowLeft" && this.mechanicMenu.activeIndex > 0) {
        this.mechanicMenu.activeIndex--;
        this.scrollIntoView();
      } else if (
        event.key === "ArrowRight" &&
        this.mechanicMenu.activeIndex < this.mechanicMenu.categories.length - 1
      ) {
        this.mechanicMenu.activeIndex++;
        this.scrollIntoView();
      } else if (event.key === "Enter") {
        item = this.mechanicMenu.categories[this.mechanicMenu.activeIndex];
        if (item.type !== "item") {
          currentIndex = this.mechanicMenu.activeIndex;
          currentMechanic = this.mechanicMenu.categories;
        }
        if (item.type == "category") {
          firstMenu = false; 
          this.mechanicMenu.categories = [];
          Object.keys(item.items).forEach((x) => {
            let subCategory = item.items[x];
            this.mechanicMenu.activeIndex = 0;
            if (subCategory.items) {
                this.post('rotateCamera', {menu: subCategory.type, objectId: 0, component: x})
                this.mechanicMenu.categories.push({
                    name: x,
                    img: "assets/img/icon/" + subCategory.img + ".png",
                    items: subCategory.items,
                    type: "category",
                });
            } else {
              if (subCategory.modId === 23) { this.post('rotateCamera', {menu: false, objectId: 3, component: item.name})} else {
                this.post('rotateCamera', {menu: false, objectId: 0, component: item.name})
              }
              this.mechanicMenu.categories.push({
                img: subCategory.img && "assets/img/icon/"+subCategory.img+".png" || item.img,
                modId: subCategory.modId,
                name: subCategory.label || x,
                mod: subCategory.img || subCategory.mod,
                price: subCategory.price || 0,
                type: "item",
              });
            }
          });
          // this.mechanicMenu.panelMenu de var
          if (item.category === "fitment" || item.category === item.name) {
            fetch(`https://dusa_mechanic/getFitment`, {
                method: "POST",
              headers: {
                "Content-Type": "application/json; charset=UTF-8",
              },
              body: JSON.stringify({}),
            })
              .then((fitment) => fitment.json())
              .then((fitment) => {
                if (fitment === false) {
                    return;
                }
                // this.post('rotateCamera', {menu: false, objectId: 3, component: 'wheel'})
                Object.keys(fitment).forEach((e) => {
                  this.fitMenu.fitMenu.forEach((x) => {
                    if (x.type === e) {
                      x.value = (fitment[e].toFixed(3));
                    }
                  })
                })
                // this.mechanicMenu.panelView = false;
                this.fitMenu.enabled = true;
              });
          } else if (item.category === "paintbrush" || item.category === item.name) {
            this.mechanicMenu.colorMenu = true;
          }
        } else if (item.type == "item") {
          firstMenu = false;
          this.buyItem(item);
          this.post('applyModifyTemporarily');
        }
      } else if (event.key === "Backspace") {
        this.mechanicMenu.activeIndex = currentIndex;
        if (firstMenu) { this.mechanicMenu.enabled = false; menuOpened = false; this.post('applyModify', {bought: false}); this.post('freeCam', {bool: false}); this.post('closeUI'); return; }
        if (!currentMechanic) { this.mechanicMenu.enabled = false; menuOpened = false; this.post('freeCam', {bool: false}); this.post('closeUI'); return; }
        if (this.fitMenu.enabled) this.fitMenu.enabled = false; this.mechanicMenu.enabled = true;
        if (this.mechanicMenu.colorMenu) this.mechanicMenu.colorMenu = false; this.mechanicMenu.enabled = true;
        this.post('rotateCamera', {menu: "menu", objectId: 0, component: false})
        this.mechanicMenu.categories = [];
        if (newMechanic !== currentMechanic) {
          firstMenu = false;
          newMechanic = currentMechanic;
          Object.keys(newMechanic).forEach((x) => {
            let categories = newMechanic[x]
            if (categories.items) {
              this.post('rotateCamera', {menu: categories.type, objectId: 0, component: x})
              this.mechanicMenu.categories.push({
                  name: categories.name,
                  img: categories.img,
                  category: categories.category,
                  items: categories.items,
                  type: "category",
              });
            } else {
              if (categories.modId === 23) { this.post('rotateCamera', {menu: false, objectId: 3, component: newMechanic.name})} else {
                this.post('rotateCamera', {menu: false, objectId: 0, component: newMechanic.name})
              }
              this.post('removeHover')
              // if (!this.mechanicMenu.cachedParts.length) this.post('removeHover');
              // this.mechanicMenu.cachedParts.forEach(e =>{ if(e.name !== item.name) this.post('removeHover'); })

              // if (this.canRemove(categories)) { this.post('removeHover')}
              this.mechanicMenu.categories.push({
                img: categories.img,
                modId: categories.modId,
                name: categories.name,
                mod: categories.mod,
                price: categories.price || 0,
                type: "item",
              });
            }
          });
        } else {
          firstMenu = true;
          firstCategory.forEach((e) => {
            this.mechanicMenu.categories.push({
              name: e.label,
              category: e.category,
              img: "assets/img/icon/" + e.img + ".png",
              items: e.items,
              type: "category",
            });
          })
        }
        this.scrollIntoView();
      }
    },
    canRemove: function(item) {
      if (this.mechanicMenu.cachedParts.length) {
        this.mechanicMenu.cachedParts.forEach(e =>{
          if(e.name !== item.name) return true;
          if (e.name === item.name) { 
            return false;
          }
        })
      } else {
        return true;
      }
    },
    closePaint() {
      this.mechanicMenu.colorMenu = false; 
      this.openUI('mechanic', true)
      firstCategory.forEach((e) => {
        this.mechanicMenu.categories.push({
          name: e.label,
          category: e.category,
          img: "assets/img/icon/" + e.img + ".png",
          items: e.items,
          type: "category",
        });
      })
    },
    selectCarCategory: function (index) {
      if (!this.mechanicMenu.enabled) return;
      this.mechanicMenu.activeIndex = index;
      setTimeout(() => {
          this.scrollIntoView();
      }, 100);
    },
    buyItem: function (item) {
      if (this.itemSelected(item)) {
        let findItem = this.mechanicMenu.card.findIndex(x => x.modId == item.modId);
        if (findItem != -1) {
            this.mechanicMenu.card.splice(findItem, 1);
        }
        return;
      }
      let findItem = this.mechanicMenu.card.findIndex(x => x.modId == item.modId);
      if (findItem != -1) {
        this.mechanicMenu.card.splice(findItem, 1);
        this.mechanicMenu.card.push({
          name: item.name,
          price: item.price,
          img: item.img,
          modId: item.modId,
          mod: item.mod,
        });
      } else {
        this.mechanicMenu.card.push({
          name: item.name,
          price: item.price,
          img: item.img,
          modId: item.modId,
          mod: item.mod,
        });
      }
      this.mechanicMenu.cachedParts.push({
        name: item.name,
        modId: item.modId,
        mod: item.mod,
      })
    },
    enterItem: function(index){
      let item = this.mechanicMenu.categories[index];
      if (item.type == "category") {
        firstMenu = false; 
        this.mechanicMenu.categories = [];
        Object.keys(item.items).forEach((x) => {
          let subCategory = item.items[x];
          this.mechanicMenu.activeIndex = 0;
          if (subCategory.items) {
              this.post('rotateCamera', {menu: subCategory.type, objectId: 0, component: x})
              this.mechanicMenu.categories.push({
                  name: x,
                  img: "assets/img/icon/" + subCategory.img + ".png",
                  items: subCategory.items,
                  type: "category",
              });
          } else {
            if (subCategory.modId === 23) { this.post('rotateCamera', {menu: false, objectId: 3, component: item.name})} else {
              this.post('rotateCamera', {menu: false, objectId: 0, component: item.name})
            }
            this.mechanicMenu.categories.push({
              img: subCategory.img && "assets/img/icon/"+subCategory.img+".png" || item.img,
              modId: subCategory.modId,
              name: subCategory.label || x,
              mod: subCategory.img || subCategory.mod,
              price: subCategory.price || 0,
              type: "item",
            });
          }
        });
        // this.mechanicMenu.panelMenu de var
        if (item.category === "fitment" || item.category === item.name) {
          fetch(`https://dusa_mechanic/getFitment`, {
              method: "POST",
            headers: {
              "Content-Type": "application/json; charset=UTF-8",
            },
            body: JSON.stringify({}),
          })
            .then((fitment) => fitment.json())
            .then((fitment) => {
              if (fitment === false) {
                  return;
              }
              this.post('rotateCamera', {menu: false, objectId: 3, component: 'wheel'})
              Object.keys(fitment).forEach((e) => {
                this.fitMenu.fitMenu.forEach((x) => {
                  if (x.type === e) {
                    x.value = (fitment[e].toFixed(3));
                  }
                })
              })
              this.fitMenu.enabled = true;
            });
        } else if (item.category === "paintbrush" || item.category === item.name) {
          this.mechanicMenu.colorMenu = true;
        }
      } 
    },
    itemSelected: function (item) { 
      if (!this.mechanicMenu.enabled) return;
      if(item.type == "category") return;
      let findItem = this.mechanicMenu.card.findIndex(x => x.modId == item.modId);
      if(findItem != -1){
          let findItem2 = this.mechanicMenu.card.findIndex(x => x.mod == item.mod);
          if (findItem2 != -1) {
              return true;
          }
          else {
              return false;
          }
      } else{
          return false;
      }
    },
    scrollIntoView() {
      if (!this.mechanicMenu.enabled) return;
      const activeCategoryElement = document.querySelector('.car-category-item.active');
      if (activeCategoryElement) {
          activeCategoryElement.scrollIntoView({
              behavior: 'smooth',
              block: 'center',
              inline: 'center'
          });
      }
    },
    washCar: function () {
      console.log("washCar");
    },
    fixCar: function () {
      this.post('repairVehicle')
    },
    applyFit: function () {
      this.fitMenu.enabled = false;
      this.post('rotateCamera', {menu: "menu", objectId: 0, component: false})
      this.openUI('mechanic', true)
      firstCategory.forEach((e) => {
        this.mechanicMenu.categories.push({
          name: e.label,
          category: e.category,
          img: "assets/img/icon/" + e.img + ".png",
          items: e.items,
          type: "category",
        });
      })
      this.post('applyFitment')
    },
    changeColorMenu: function (type) {
      if(type == "left"){
          if(this.mechanicMenu.activeColor == 0){
              this.mechanicMenu.activeColor = this.mechanicMenu.carColor.length - 1;
          }else{
              this.mechanicMenu.activeColor--;
          }
      }
      else if(type == "right"){
          if(this.mechanicMenu.activeColor == this.mechanicMenu.carColor.length - 1){
              this.mechanicMenu.activeColor = 0;
          }else{
              this.mechanicMenu.activeColor++;
          }
      }
  },
  changeColorType1: function (type) {
      if(type == "left"){
          if(this.mechanicMenu.type1 == 0){
              this.mechanicMenu.type1 = this.mechanicMenu.carColorType1.length - 1;
              this.mechanicMenu.carColor[0].type = this.mechanicMenu.carColorType1[this.mechanicMenu.type1].type;
          }else{
              this.mechanicMenu.type1--;
              this.mechanicMenu.carColor[0].type = this.mechanicMenu.carColorType1[this.mechanicMenu.type1].type;
          }
      }
      else if(type == "right"){
          if(this.mechanicMenu.type1 == this.mechanicMenu.carColorType1.length - 1){
              this.mechanicMenu.type1 = 0;
              this.mechanicMenu.carColor[0].type = this.mechanicMenu.carColorType1[this.mechanicMenu.type1].type;
          }else{
              this.mechanicMenu.type1++;
              this.mechanicMenu.carColor[0].type = this.mechanicMenu.carColorType1[this.mechanicMenu.type1].type;
          }
        }
      this.post('hoverModel', {modId: 'paintType1', mod: this.mechanicMenu.carColor[0]})
  },
  changeColorType2: function (type) {
      if(type == "left"){
          if(this.mechanicMenu.type2 == 0){
              this.mechanicMenu.type2 = this.mechanicMenu.carColorType2.length - 1;
              this.mechanicMenu.carColor[1].type = this.mechanicMenu.carColorType2[this.mechanicMenu.type2].type;
          }else{
              this.mechanicMenu.type2--;
              this.mechanicMenu.carColor[1].type = this.mechanicMenu.carColorType2[this.mechanicMenu.type2].type;
          }
      }
      else if(type == "right"){
          if(this.mechanicMenu.type2 == this.mechanicMenu.carColorType2.length - 1){
              this.mechanicMenu.type2 = 0;
              this.mechanicMenu.carColor[1].type = this.mechanicMenu.carColorType2[this.mechanicMenu.type2].type;
          }else{
              this.mechanicMenu.type2++;
              this.mechanicMenu.carColor[1].type = this.mechanicMenu.carColorType2[this.mechanicMenu.type2].type;
          }
      }
      this.post('hoverModel', {modId: 'paintType2', mod: this.mechanicMenu.carColor[1]})
  },
  changeWheelColor: function (color) {
    this.mechanicMenu.carColor[2].color = color;
    this.post('hoverModel', {modId: 'wheelColor', mod: this.mechanicMenu.carColor[2].color})
  },
  addColorCard: function () {
      let findItem = this.mechanicMenu.card.findIndex(x => x.modId == "customColorD");
      if (findItem != -1) {
          this.mechanicMenu.card.splice(findItem, 1);
      }
      else {
          this.mechanicMenu.card.push({
              name: this.mechanicMenu.info.color,
              price: this.mechanicMenu.colorPrice,
              img: "assets/img/icon/paintbrush.png",
              modId: "customColorD",
              mod: "1231491249",
          });
      }
    },
    deleteCard: function (item) {
      let findItem = this.mechanicMenu.card.findIndex(
        (x) => x.modId == item.modId
      );
      if (findItem != -1) {
        this.mechanicMenu.card.splice(findItem, 1);
      }
    },
    buyCash: function () {
      let total = 0;
      this.mechanicMenu.card.forEach(element => {
          total += element.price;
      });
      fetch(`https://dusa_mechanic/checkMoney`, {
        method: "POST",
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: JSON.stringify({
        totalPrice: total - (total * (this.bossMenu.discount / 100)),
        type: 'cash'
      }),
    })
      .then((hasMoney) => hasMoney.json())
      .then((hasMoney) => {
        if (hasMoney === false) {
          this.post('notEnoughMoney')
            return;
        }
        this.post('applyModify', {cart: this.mechanicMenu.card, type: 'cash', bought: true, hasMoney: hasMoney[0], totalPrice: hasMoney[1]});
        this.mechanicMenu.card = [];
        this.mechanicMenu.enabled = false;
        menuOpened = false;
        this.post('freeCam', {bool: false}); this.post('closeUI');
      });
    },
    buyCard: function () {
      let total = 0;
      this.mechanicMenu.card.forEach(element => {
          total += element.price;
      });
      fetch(`https://dusa_mechanic/checkMoney`, {
        method: "POST",
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: JSON.stringify({
        totalPrice: total - (total * (this.bossMenu.discount / 100)),
        type: 'card'
      }),
    })
      .then((hasMoney) => hasMoney.json())
      .then((hasMoney) => {
        if (hasMoney === false) {
            this.post('notEnoughMoney')
            return;
        }
        this.post('applyModify', {cart: this.mechanicMenu.card, type: 'card', bought: true, hasMoney: hasMoney[0], totalPrice: hasMoney[1]});
        this.mechanicMenu.card = [];
        this.mechanicMenu.enabled = false;
        menuOpened = false;
        this.post('freeCam', {bool: false}); this.post('closeUI');
      });
    },
    buyCompany: function () {
      let total = 0;
      this.mechanicMenu.card.forEach(element => {
          total += element.price;
      });
      fetch(`https://dusa_mechanic/checkMoney`, {
        method: "POST",
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: JSON.stringify({
        totalPrice: total - (total * (this.bossMenu.discount / 100)),
        type: 'company'
      }),
      })
      .then((hasMoney) => hasMoney.json())
      .then((hasMoney) => {
        if (hasMoney === false) {
            this.post('notEnoughMoney')
            return;
        }
        this.post('applyModify', {cart: this.mechanicMenu.card, type: 'company', bought: true, hasMoney: hasMoney[0], totalPrice: hasMoney[1]});
        this.mechanicMenu.card = [];
        this.mechanicMenu.enabled = false;
        menuOpened = false;
        this.post('freeCam', {bool: false}); this.post('closeUI');
      });
    },
    clearCard: function () {
      this.mechanicMenu.card = [];
    },

    // Craft Menu
    checkCraft: function (item) {
      let check = true;
      item.required.forEach(element => {
          if(element.owned < element.count){
              check = false;
          }
      });
      return check;
    },
    checkSingleCraft: function (item) {
      if(item.owned < item.count){ 
          return false;
      }
      else{
          return true;
      }
    },
    craftItem: function (item) {
      this.post('craft', item);
      this.openUI("craft", false);
      this.post('closeCraft');
    },
    selectCraft: function (item) {
      if(item.selected){
        this.post('destroyPreview')
          item.selected = false;
          return;
      }
      else{
          this.craftMenu.items.forEach(element => {
              element.selected = false;
          });
          this.post('destroyPreview')
          item.selected = true;
          this.post('previewObject', item)
          return;
      }
  },

    // Lift Control
    liftUp: function () {
      this.liftControl.up = true;
      this.liftControl.down = false;
      this.liftControl.detachVehicle = false;
      this.liftControl.stop = false;
      this.post('lift', {action: 'up'})
    },
    liftDown: function () {
      this.liftControl.up = false;
      this.liftControl.down = true;
      this.liftControl.detachVehicle = false;
      this.liftControl.stop = false;
      this.post('lift', {action: 'down'})
    },
    liftStop: function () {
      this.liftControl.up = false;
      this.liftControl.down = false;
      this.liftControl.detachVehicle = false;
      this.liftControl.stop = true;
      this.post('lift', {action: 'stop'})
    },

    detachVehicle: function () {
      this.liftControl.up = false;
      this.liftControl.down = false;
      this.liftControl.stop = false;
      this.liftControl.detachVehicle = true;
      this.post('lift', {action: 'detach'})
    },

    // Lift Control 2
    liftSabit: function () {
        this.liftControl2.sabit = true;
        this.liftControl2.sabitcikar = false;
        this.liftControl2.rampayiindir = false;
        this.post('attachVehicle');
      },
    liftSabitCikar: function () {
        this.liftControl2.sabit = false;
        this.liftControl2.sabitcikar = true;
        this.liftControl2.rampayiindir = false;
        this.post('detachVehicle');
    },
    liftRampayiIndir: function () {
        this.liftControl2.sabit = false;
        this.liftControl2.sabitcikar = false;
        this.liftControl2.rampayiindir = true;
        this.post('deployRamp');
    },

    hideUI: function(bool) {
      this.mechanicMenu.enabled = bool;
    },

    post: function (event, data) {
      var xhr = new XMLHttpRequest();
      xhr.open("POST", "https://dusa_mechanic/" + event);
      xhr.setRequestHeader("Content-Type", "application/json");
      xhr.onreadystatechange = function () {
        if (xhr.readyState === 4 && xhr.status === 200) {
        }
      };
      xhr.send(JSON.stringify({ data }));
    },

    // Translate
    translate: function(tr) {
      this.bossMenu.info.dashboard = tr.dashboard
      this.bossMenu.info.settings = tr.settings
      this.bossMenu.info.employees = tr.employees
      this.bossMenu.info.managePerm = tr.managePerm
      this.bossMenu.info.managePermInfo = tr.managePermInfo
      this.bossMenu.info.employeeslist = tr.employeeslist
      this.bossMenu.info.addEmployee = tr.addEmployee
      this.bossMenu.info.addnewemployee = tr.addnewemployee
      this.bossMenu.info.addnewemployeedesc = tr.addnewemployeedesc
      this.bossMenu.info.sellcompany = tr.sellcompany
      this.bossMenu.info.totalassets = tr.totalassets
      this.bossMenu.info.totalemployees = tr.totalemployees
      this.bossMenu.info.depositwithdraw = tr.depositwithdraw
      this.bossMenu.info.withdraw = tr.withdraw
      this.bossMenu.info.deposit = tr.deposit
      this.bossMenu.info.mechanicname = tr.mechanicname
      this.bossMenu.info.setaname = tr.setaname
      this.bossMenu.info.mechanicdiscount = tr.mechanicdiscount
      this.bossMenu.info.setdiscount = tr.setdiscount
      this.bossMenu.info.vehiclecleaning = tr.vehiclecleaning
      this.bossMenu.info.updatefee = tr.updatefee
      this.bossMenu.info.areyousure = tr.areyousure
      this.bossMenu.info.yes = tr.yes
      this.bossMenu.info.no = tr.no
      this.bossMenu.info.history = tr.history
      this.bossMenu.info.saveaname = tr.saveaname
      this.bossMenu.info.savediscount = tr.savediscount
      this.bossMenu.info.updateRank = tr.updateRank
      this.bossMenu.info.kickEmployee = tr.kickEmployee
      this.bossMenu.info.applyChanges = tr.applyChanges

      this.notifyText.info.error = tr.error
      this.notifyText.info.success = tr.success
      this.notifyText.info.info = tr.info

      this.mechanicMenu.info.enter = tr.enter
      this.mechanicMenu.info.buy =tr.buy
      this.mechanicMenu.info.buyed = tr.buyed
      this.mechanicMenu.info.washCar = tr.washCar
      this.mechanicMenu.info.fixCar = tr.fixCar
      this.mechanicMenu.info.colorTitle = tr.colorTitle
      this.mechanicMenu.info.primaryColor = tr.primaryColor
      this.mechanicMenu.info.secondaryColor = tr.secondaryColor
      this.mechanicMenu.info.classic = tr.classic
      this.mechanicMenu.info.metallic = tr.metallic
      this.mechanicMenu.info.matte = tr.matte
      this.mechanicMenu.info.metal = tr.metal
      this.mechanicMenu.info.chrome = tr.chrome
      this.mechanicMenu.info.pearlescent = tr.pearlescent
      this.mechanicMenu.info.card = tr.card
      this.mechanicMenu.info.delete = tr.delete
      this.mechanicMenu.info.total = tr.total
      this.mechanicMenu.info.paycash = tr.paycash
      this.mechanicMenu.info.paycard = tr.paycard
      this.mechanicMenu.info.clearCard = tr.clearCard
      this.mechanicMenu.info.addCard = tr.addCard
      this.mechanicMenu.info.close = tr.close
      this.mechanicMenu.info.color = tr.color
      this.mechanicMenu.info.deleteCard = tr.deleteCard
      this.mechanicMenu.info.notenoughmoney = tr.notenoughmoney

      this.fitMenu.info.fitMenu = tr.fitMenu
      this.fitMenu.info.wheelsWidth = tr.wheelsWidth
      this.fitMenu.info.wheelsFrontLeft = tr.wheelsFrontLeft
      this.fitMenu.info.wheelsFrontRight = tr.wheelsFrontRight
      this.fitMenu.info.wheelsRearLeft = tr.wheelsRearLeft
      this.fitMenu.info.wheelsRearRight = tr.wheelsRearRight
      this.fitMenu.info.wheelsFrontCamberLeft = tr.wheelsFrontCamberLeft
      this.fitMenu.info.wheelsFrontCamberRight = tr.wheelsFrontCamberRight
      this.fitMenu.info.wheelsRearCamberLeft = tr.wheelsRearCamberLeft
      this.fitMenu.info.wheelsRearCamberRight = tr.wheelsRearCamberRight
      this.fitMenu.info.applySettings = tr.applySettings

      this.tuningMenu.info.tuningtitle = tr.tuningtitle
      this.tuningMenu.info.tuninginfo = tr.tuninginfo
      this.tuningMenu.info.mods = tr.mods
      this.tuningMenu.info.detail = tr.detail
      this.tuningMenu.info.neon = tr.neon
      this.tuningMenu.info.headlights = tr.headlights
      this.tuningMenu.info.select = tr.select
      this.tuningMenu.info.selected = tr.selected
      this.tuningMenu.info.applySettings = tr.applySettings
      this.tuningMenu.info.cancel = tr.cancel
      this.tuningMenu.info.boost = tr.boost
      this.tuningMenu.info.acceleration = tr.acceleration
      this.tuningMenu.info.breaking = tr.breaking
      this.tuningMenu.info.gearchange = tr.gearchange
      this.tuningMenu.info.drivetrain = tr.drivetrain
      this.tuningMenu.info.front = tr.front
      this.tuningMenu.info.back = tr.back
      this.tuningMenu.info.left = tr.left
      this.tuningMenu.info.right = tr.right
      this.tuningMenu.info.rainbow = tr.rainbow
      this.tuningMenu.info.default = tr.default
      this.tuningMenu.info.snake = tr.snake
      this.tuningMenu.info.crisscross = tr.crisscross
      this.tuningMenu.info.lightnings = tr.lightnings
      this.tuningMenu.info.fourways = tr.fourways
      this.tuningMenu.info.blinking = tr.blinking

      this.craftMenu.info.craft = tr.craft
      this.craftMenu.info.bench = tr.bench
      this.craftMenu.info.youritems = tr.youritems
      this.craftMenu.info.craftdesc = tr.craftdesc
      this.craftMenu.info.needItems = tr.needItems
      this.craftMenu.info.craftItem = tr.craftItem

      this.liftControl.info.up = tr.up
      this.liftControl.info.stop = tr.stop
      this.liftControl.info.down = tr.down
      this.liftControl.info.lifttitle = tr.lifttitle
      this.liftControl.info.liftdesc = tr.liftdesc

      this.liftControl2.info.sabit = tr.sabit
      this.liftControl2.info.sabitcikar = tr.sabitcikar
      this.liftControl2.info.rampayiindir = tr.rampayiindir
      this.liftControl2.info.towtitle = tr.towtitle
      this.liftControl2.info.towdesc = tr.towdesc
      this.liftControl2.info.detachVehicle = tr.detachVehicle
    },

    //Notify
    notify: function (type, text) {
      let notify = document.getElementById("notify");
      let delayA = this.notifyDelay / 1000 - 1;
      if (type === "error") {
        // div append innerhtml
        var number = Math.floor(Math.random() * 1000 + 1);
        notify.insertAdjacentHTML(
          "beforeend",
          `
         <div class="notfiyC error" id="${number}">
         <div class="cont">
             <div class="icon">
             <svg width="25" height="25" viewBox="0 0 25 25" fill="none" xmlns="http://www.w3.org/2000/svg">
             <path d="M12.44 0C9.9796 0 7.57446 0.729593 5.52871 2.09652C3.48296 3.46344 1.8885 5.4063 0.946944 7.67942C0.00539006 9.95253 -0.240963 12.4538 0.239037 14.8669C0.719037 17.28 1.90383 19.4966 3.6436 21.2364C5.38336 22.9762 7.59996 24.161 10.0131 24.641C12.4262 25.121 14.9275 24.8746 17.2006 23.9331C19.4737 22.9915 21.4166 21.397 22.7835 19.3513C24.1504 17.3055 24.88 14.9004 24.88 12.44C24.8765 9.14177 23.5648 5.97963 21.2326 3.64744C18.9004 1.31524 15.7382 0.00348298 12.44 0ZM16.9447 15.5907C17.0336 15.6796 17.1041 15.7851 17.1523 15.9013C17.2004 16.0175 17.2251 16.142 17.2251 16.2677C17.2251 16.3934 17.2004 16.5179 17.1523 16.6341C17.1041 16.7503 17.0336 16.8558 16.9447 16.9447C16.8558 17.0336 16.7503 17.1041 16.6341 17.1523C16.5179 17.2004 16.3934 17.2251 16.2677 17.2251C16.142 17.2251 16.0175 17.2004 15.9013 17.1523C15.7851 17.1041 15.6796 17.0336 15.5907 16.9447L12.44 13.7928L9.28933 16.9447C9.20043 17.0336 9.09488 17.1041 8.97871 17.1523C8.86255 17.2004 8.73805 17.2251 8.61231 17.2251C8.48658 17.2251 8.36207 17.2004 8.24591 17.1523C8.12974 17.1041 8.0242 17.0336 7.93529 16.9447C7.84638 16.8558 7.77585 16.7503 7.72774 16.6341C7.67962 16.5179 7.65486 16.3934 7.65486 16.2677C7.65486 16.142 7.67962 16.0175 7.72774 15.9013C7.77585 15.7851 7.84638 15.6796 7.93529 15.5907L11.0872 12.44L7.93529 9.28933C7.75573 9.10977 7.65486 8.86624 7.65486 8.61231C7.65486 8.35837 7.75573 8.11484 7.93529 7.93528C8.11485 7.75572 8.35838 7.65485 8.61231 7.65485C8.86624 7.65485 9.10978 7.75572 9.28933 7.93528L12.44 11.0871L15.5907 7.93528C15.6796 7.84637 15.7851 7.77585 15.9013 7.72773C16.0175 7.67962 16.142 7.65485 16.2677 7.65485C16.3934 7.65485 16.5179 7.67962 16.6341 7.72773C16.7503 7.77585 16.8558 7.84637 16.9447 7.93528C17.0336 8.02419 17.1041 8.12974 17.1523 8.2459C17.2004 8.36207 17.2251 8.48657 17.2251 8.61231C17.2251 8.73804 17.2004 8.86254 17.1523 8.97871C17.1041 9.09487 17.0336 9.20042 16.9447 9.28933L13.7929 12.44L16.9447 15.5907Z" fill="#DD6262"/>
             </svg>
             
             </div>
             <div class="text">
                 <h1>${this.notifyText.error}</h1>
                 <p>${text}</p>
             </div>
         </div>
         <svg width="262" height="69" viewBox="0 0 262 69" fill="none" xmlns="http://www.w3.org/2000/svg">
         <g clip-path="url(#clip0_51_1420)">
         <rect width="262" height="68.3478" rx="7.23118" fill="url(#paint0_linear_51_1420)"/>
         <g filter="url(#filter0_f_51_1420)">
         <circle cx="9.5" cy="-55.686" r="93.5" fill="white" fill-opacity="0.25"/>
         </g>
         <g filter="url(#filter1_f_51_1420)">
         <circle cx="111" cy="695.814" r="282" fill="#876544" fill-opacity="0.22"/>
         </g>
         <path d="M25 -16C25 -17.1046 25.8954 -18 27 -18H43C44.1046 -18 45 -17.1046 45 -16V0.763931C45 1.52147 44.572 2.214 43.8944 2.55279L35.8944 6.55279C35.3314 6.83431 34.6686 6.83431 34.1056 6.55279L26.1056 2.55279C25.428 2.214 25 1.52148 25 0.763931V-16Z" fill="#DD6262"/>
         <path d="M45 84C45 85.1046 44.1046 86 43 86L27 86C25.8954 86 25 85.1046 25 84L25 67.2361C25 66.4785 25.428 65.786 26.1056 65.4472L34.1056 61.4472C34.6686 61.1657 35.3314 61.1657 35.8944 61.4472L43.8944 65.4472C44.572 65.786 45 66.4785 45 67.2361L45 84Z" fill="#DD6262"/>
         </g>
         <rect x="0.5" y="0.5" width="261" height="67.3478" rx="6.73118" stroke="#DD6262"/>
         <defs>
         <filter id="filter0_f_51_1420" x="-323" y="-388.186" width="665" height="665" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
         <feFlood flood-opacity="0" result="BackgroundImageFix"/>
         <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
         <feGaussianBlur stdDeviation="119.5" result="effect1_foregroundBlur_51_1420"/>
         </filter>
         <filter id="filter1_f_51_1420" x="-571.994" y="12.8197" width="1365.99" height="1365.99" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
         <feFlood flood-opacity="0" result="BackgroundImageFix"/>
         <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
         <feGaussianBlur stdDeviation="200.497" result="effect1_foregroundBlur_51_1420"/>
         </filter>
         <linearGradient id="paint0_linear_51_1420" x1="4.28828" y1="7.12885" x2="78.5337" y2="158.981" gradientUnits="userSpaceOnUse">
         <stop stop-color="#000103"/>
         <stop offset="1" stop-color="#010104"/>
         </linearGradient>
         <clipPath id="clip0_51_1420">
         <rect width="262" height="68.3478" rx="7.23118" fill="white"/>
         </clipPath>
         </defs>
         </svg>
         
     </div>
          `
        );
        // Delete İtem And Anim
        let item = document.getElementById(number);
        gsap.to(item, { left: 0, duration: 0.5, ease: "power2.out" });
        gsap.to(item, {
          left: "-20vw",
          duration: 0.5,
          ease: "power2.out",
          delay: delayA,
        });
        setTimeout(() => {
          item.remove();
        }, this.notifyDelay);
      } else if (type === "success") {
        // div append innerhtml
        var number = Math.floor(Math.random() * 1000 + 1);
        notify.insertAdjacentHTML(
          "beforeend",
          `<div class="notfiyC success" id="${number}">
          <div class="cont">
              <div class="icon">
              <svg width="26" height="26" viewBox="0 0 26 26" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M13 0C10.4288 0 7.91543 0.762437 5.77759 2.1909C3.63975 3.61935 1.97351 5.64968 0.989572 8.02512C0.0056327 10.4006 -0.251811 13.0144 0.249797 15.5362C0.751405 18.0579 1.98953 20.3743 3.80762 22.1924C5.6257 24.0105 7.94208 25.2486 10.4638 25.7502C12.9856 26.2518 15.5995 25.9944 17.9749 25.0104C20.3503 24.0265 22.3807 22.3603 23.8091 20.2224C25.2376 18.0846 26 15.5712 26 13C25.9964 9.5533 24.6256 6.24882 22.1884 3.81163C19.7512 1.37445 16.4467 0.00363977 13 0ZM18.7075 10.7075L11.7075 17.7075C11.6146 17.8005 11.5043 17.8742 11.3829 17.9246C11.2615 17.9749 11.1314 18.0008 11 18.0008C10.8686 18.0008 10.7385 17.9749 10.6171 17.9246C10.4957 17.8742 10.3854 17.8005 10.2925 17.7075L7.29251 14.7075C7.10486 14.5199 6.99945 14.2654 6.99945 14C6.99945 13.7346 7.10486 13.4801 7.29251 13.2925C7.48015 13.1049 7.73464 12.9994 8.00001 12.9994C8.26537 12.9994 8.51987 13.1049 8.70751 13.2925L11 15.5863L17.2925 9.2925C17.3854 9.19959 17.4957 9.12589 17.6171 9.07561C17.7385 9.02532 17.8686 8.99944 18 8.99944C18.1314 8.99944 18.2615 9.02532 18.3829 9.07561C18.5043 9.12589 18.6146 9.19959 18.7075 9.2925C18.8004 9.38541 18.8741 9.49571 18.9244 9.6171C18.9747 9.7385 19.0006 9.8686 19.0006 10C19.0006 10.1314 18.9747 10.2615 18.9244 10.3829C18.8741 10.5043 18.8004 10.6146 18.7075 10.7075Z" fill="#62DD9B"/>
              </svg>
              
              </div>
              <div class="text">
                  <h1>${this.notifyText.success}</h1>
                  <p>${text}</p>
              </div>
          </div>
          <svg width="262" height="69" viewBox="0 0 262 69" fill="none" xmlns="http://www.w3.org/2000/svg">
          <g clip-path="url(#clip0_51_1378)">
          <rect width="262" height="68.3478" rx="7.23118" fill="url(#paint0_linear_51_1378)"/>
          <g filter="url(#filter0_f_51_1378)">
          <circle cx="9.5" cy="-55.686" r="93.5" fill="white" fill-opacity="0.25"/>
          </g>
          <g filter="url(#filter1_f_51_1378)">
          <circle cx="111" cy="695.814" r="282" fill="#876544" fill-opacity="0.22"/>
          </g>
          <path d="M25 -16C25 -17.1046 25.8954 -18 27 -18H43C44.1046 -18 45 -17.1046 45 -16V0.763931C45 1.52147 44.572 2.214 43.8944 2.55279L35.8944 6.55279C35.3314 6.83431 34.6686 6.83431 34.1056 6.55279L26.1056 2.55279C25.428 2.214 25 1.52148 25 0.763931V-16Z" fill="#62DD9B"/>
          <path d="M45 84C45 85.1046 44.1046 86 43 86L27 86C25.8954 86 25 85.1046 25 84L25 67.2361C25 66.4785 25.428 65.786 26.1056 65.4472L34.1056 61.4472C34.6686 61.1657 35.3314 61.1657 35.8944 61.4472L43.8944 65.4472C44.572 65.786 45 66.4785 45 67.2361L45 84Z" fill="#62DD9B"/>
          </g>
          <rect x="0.5" y="0.5" width="261" height="67.3478" rx="6.73118" stroke="#62DD9B"/>
          <defs>
          <filter id="filter0_f_51_1378" x="-323" y="-388.186" width="665" height="665" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
          <feFlood flood-opacity="0" result="BackgroundImageFix"/>
          <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
          <feGaussianBlur stdDeviation="119.5" result="effect1_foregroundBlur_51_1378"/>
          </filter>
          <filter id="filter1_f_51_1378" x="-571.994" y="12.8197" width="1365.99" height="1365.99" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
          <feFlood flood-opacity="0" result="BackgroundImageFix"/>
          <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
          <feGaussianBlur stdDeviation="200.497" result="effect1_foregroundBlur_51_1378"/>
          </filter>
          <linearGradient id="paint0_linear_51_1378" x1="4.28828" y1="7.12885" x2="78.5337" y2="158.981" gradientUnits="userSpaceOnUse">
          <stop stop-color="#000103"/>
          <stop offset="1" stop-color="#010104"/>
          </linearGradient>
          <clipPath id="clip0_51_1378">
          <rect width="262" height="68.3478" rx="7.23118" fill="white"/>
          </clipPath>
          </defs>
          </svg>
          
      </div>
      `
        );

        // Delete İtem And Anim
        let item = document.getElementById(number);
        gsap.to(item, { left: 0, duration: 0.5, ease: "power2.out" });
        gsap.to(item, {
          left: "-20vw",
          duration: 0.5,
          ease: "power2.out",
          delay: delayA,
        });
        setTimeout(() => {
          item.remove();
        }, this.notifyDelay);
      } else if (type === "info") {
        // div append innerhtml
        var number = Math.floor(Math.random() * 1000 + 1);
        notify.insertAdjacentHTML(
          "beforeend",
          `
          <div class="notfiyC info" id="${number}">
          <div class="cont">
              <div class="icon">
              <svg width="25" height="25" viewBox="0 0 25 25" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M12.4378 0C9.97782 0 7.5731 0.729463 5.52772 2.09614C3.48234 3.46282 1.88816 5.40534 0.946775 7.67804C0.00538907 9.95075 -0.24092 12.4516 0.238994 14.8643C0.718908 17.277 1.90349 19.4932 3.64295 21.2326C5.3824 22.9721 7.5986 24.1566 10.0113 24.6366C12.424 25.1165 14.9248 24.8702 17.1975 23.9288C19.4702 22.9874 21.4127 21.3932 22.7794 19.3478C24.1461 17.3025 24.8756 14.8977 24.8756 12.4378C24.8721 9.14014 23.5605 5.97857 21.2288 3.64679C18.897 1.31501 15.7354 0.00348236 12.4378 0ZM11.9594 5.74051C12.2432 5.74051 12.5207 5.82468 12.7567 5.98237C12.9927 6.14007 13.1767 6.3642 13.2853 6.62644C13.3939 6.88868 13.4223 7.17723 13.367 7.45562C13.3116 7.73401 13.1749 7.98972 12.9742 8.19043C12.7735 8.39113 12.5178 8.52782 12.2394 8.58319C11.961 8.63857 11.6724 8.61015 11.4102 8.50152C11.148 8.3929 10.9238 8.20896 10.7661 7.97295C10.6084 7.73695 10.5243 7.45948 10.5243 7.17564C10.5243 6.79502 10.6755 6.42999 10.9446 6.16085C11.2138 5.89171 11.5788 5.74051 11.9594 5.74051ZM13.3945 19.135C12.887 19.135 12.4003 18.9334 12.0415 18.5746C11.6826 18.2157 11.481 17.729 11.481 17.2215V12.4378C11.2273 12.4378 10.9839 12.337 10.8045 12.1575C10.6251 11.9781 10.5243 11.7348 10.5243 11.481C10.5243 11.2273 10.6251 10.9839 10.8045 10.8045C10.9839 10.6251 11.2273 10.5243 11.481 10.5243C11.9885 10.5243 12.4752 10.7259 12.8341 11.0847C13.1929 11.4436 13.3945 11.9303 13.3945 12.4378V17.2215C13.6483 17.2215 13.8916 17.3223 14.0711 17.5018C14.2505 17.6812 14.3513 17.9245 14.3513 18.1783C14.3513 18.432 14.2505 18.6754 14.0711 18.8548C13.8916 19.0342 13.6483 19.135 13.3945 19.135Z" fill="#D3DD62"/>
              </svg>
              
              </div>
              <div class="text">
                  <h1>${this.notifyText.info}</h1>
                  <p>${text}</p>
              </div>
          </div>
          <svg width="262" height="69" viewBox="0 0 262 69" fill="none" xmlns="http://www.w3.org/2000/svg">
          <g clip-path="url(#clip0_51_1433)">
          <rect width="262" height="68.3478" rx="7.23118" fill="url(#paint0_linear_51_1433)"/>
          <g filter="url(#filter0_f_51_1433)">
          <circle cx="9.5" cy="-55.686" r="93.5" fill="white" fill-opacity="0.25"/>
          </g>
          <g filter="url(#filter1_f_51_1433)">
          <circle cx="111" cy="695.814" r="282" fill="#876544" fill-opacity="0.22"/>
          </g>
          <path d="M25 -16C25 -17.1046 25.8954 -18 27 -18H43C44.1046 -18 45 -17.1046 45 -16V0.763931C45 1.52147 44.572 2.214 43.8944 2.55279L35.8944 6.55279C35.3314 6.83431 34.6686 6.83431 34.1056 6.55279L26.1056 2.55279C25.428 2.214 25 1.52148 25 0.763931V-16Z" fill="#D3DD62"/>
          <path d="M45 84C45 85.1046 44.1046 86 43 86L27 86C25.8954 86 25 85.1046 25 84L25 67.2361C25 66.4785 25.428 65.786 26.1056 65.4472L34.1056 61.4472C34.6686 61.1657 35.3314 61.1657 35.8944 61.4472L43.8944 65.4472C44.572 65.786 45 66.4785 45 67.2361L45 84Z" fill="#D3DD62"/>
          </g>
          <rect x="0.5" y="0.5" width="261" height="67.3478" rx="6.73118" stroke="#D3DD62"/>
          <defs>
          <filter id="filter0_f_51_1433" x="-323" y="-388.186" width="665" height="665" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
          <feFlood flood-opacity="0" result="BackgroundImageFix"/>
          <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
          <feGaussianBlur stdDeviation="119.5" result="effect1_foregroundBlur_51_1433"/>
          </filter>
          <filter id="filter1_f_51_1433" x="-571.994" y="12.8197" width="1365.99" height="1365.99" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
          <feFlood flood-opacity="0" result="BackgroundImageFix"/>
          <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
          <feGaussianBlur stdDeviation="200.497" result="effect1_foregroundBlur_51_1433"/>
          </filter>
          <linearGradient id="paint0_linear_51_1433" x1="4.28828" y1="7.12885" x2="78.5337" y2="158.981" gradientUnits="userSpaceOnUse">
          <stop stop-color="#000103"/>
          <stop offset="1" stop-color="#010104"/>
          </linearGradient>
          <clipPath id="clip0_51_1433">
          <rect width="262" height="68.3478" rx="7.23118" fill="white"/>
          </clipPath>
          </defs>
          </svg>
          
      </div>
          `
        );
        // Delete İtem And Anim
        let item = document.getElementById(number);
        gsap.to(item, { left: 0, duration: 0.5, ease: "power2.out" });
        gsap.to(item, {
          left: "-20vw",
          duration: 0.5,
          ease: "power2.out",
          delay: delayA,
        });
        setTimeout(() => {
          item.remove();
        }, this.notifyDelay);
      } else if (type === "hunger") {
        // div append innerhtml
        var number = Math.floor(Math.random() * 1000 + 1);
        notify.insertAdjacentHTML(
          "beforeend",
          `
          <div class="notfiyC hunger" id="${number}">
          <div class="cont">
              <div class="icon">
              <svg width="22" height="24" viewBox="0 0 22 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M21.469 0.948578V22.4176C21.469 22.6651 21.3706 22.9025 21.1956 23.0776C21.0205 23.2526 20.7831 23.351 20.5355 23.351C20.288 23.351 20.0506 23.2526 19.8755 23.0776C19.7004 22.9025 19.6021 22.6651 19.6021 22.4176V16.8169H14.0015C13.7539 16.8169 13.5165 16.7186 13.3415 16.5436C13.1664 16.3685 13.0681 16.1311 13.0681 15.8835C13.1114 13.6476 13.3938 11.4227 13.9105 9.2468C15.0516 4.52246 17.2148 1.35579 20.168 0.0909863C20.3099 0.0301852 20.4647 0.00554683 20.6186 0.0192796C20.7724 0.0330123 20.9204 0.0846869 21.0493 0.169673C21.1782 0.254659 21.284 0.370302 21.3573 0.506239C21.4305 0.642177 21.4689 0.794163 21.469 0.948578ZM10.2549 0.795728C10.2367 0.673162 10.1941 0.555463 10.1299 0.449496C10.0657 0.343529 9.98095 0.251416 9.88073 0.178529C9.78051 0.105642 9.66678 0.0534408 9.54617 0.0249697C9.42556 -0.00350145 9.30049 -0.00767226 9.17826 0.0127004C9.05602 0.0330731 8.93907 0.0775816 8.83421 0.14363C8.72936 0.209678 8.63871 0.295943 8.56754 0.397394C8.49638 0.498845 8.44613 0.613451 8.41972 0.734527C8.39331 0.855603 8.39128 0.980725 8.41374 1.10259L9.3215 6.54918H6.53404V0.948578C6.53404 0.701016 6.43569 0.463594 6.26064 0.288541C6.08559 0.113488 5.84816 0.0151446 5.6006 0.0151446C5.35304 0.0151446 5.11562 0.113488 4.94056 0.288541C4.76551 0.463594 4.66717 0.701016 4.66717 0.948578V6.54918H1.8797L2.78747 1.10259C2.80992 0.980725 2.80789 0.855603 2.78148 0.734527C2.75508 0.613451 2.70483 0.498845 2.63366 0.397394C2.5625 0.295943 2.47184 0.209678 2.36699 0.14363C2.26214 0.0775816 2.14518 0.0330731 2.02294 0.0127004C1.90071 -0.00767226 1.77564 -0.00350145 1.65503 0.0249697C1.53442 0.0534408 1.42069 0.105642 1.32047 0.178529C1.22025 0.251416 1.13555 0.343529 1.0713 0.449496C1.00705 0.555463 0.96455 0.673162 0.946268 0.795728L0.0128348 6.39633C0.00445774 6.44685 0.000165538 6.49797 0 6.54918C0.00186509 7.8721 0.471288 9.15178 1.32532 10.1621C2.17935 11.1724 3.36302 11.8484 4.66717 12.0704V22.4176C4.66717 22.6651 4.76551 22.9025 4.94056 23.0776C5.11562 23.2526 5.35304 23.351 5.6006 23.351C5.84816 23.351 6.08559 23.2526 6.26064 23.0776C6.43569 22.9025 6.53404 22.6651 6.53404 22.4176V12.0704C7.83818 11.8484 9.02185 11.1724 9.87588 10.1621C10.7299 9.15178 11.1993 7.8721 11.2012 6.54918C11.201 6.49797 11.1967 6.44685 11.1884 6.39633L10.2549 0.795728Z" fill="#DD62D8"/>
              </svg>
              
              
              </div>
              <div class="text">
                  <h1>${this.notifyText.hunger}</h1>
                  <p>${text}</p>
              </div>
          </div>
          <svg width="262" height="69" viewBox="0 0 262 69" fill="none" xmlns="http://www.w3.org/2000/svg">
          <g clip-path="url(#clip0_51_1402)">
          <rect width="262" height="68.3478" rx="7.23118" fill="url(#paint0_linear_51_1402)"/>
          <g filter="url(#filter0_f_51_1402)">
          <circle cx="9.5" cy="-55.686" r="93.5" fill="white" fill-opacity="0.25"/>
          </g>
          <g filter="url(#filter1_f_51_1402)">
          <circle cx="111" cy="695.814" r="282" fill="#876544" fill-opacity="0.22"/>
          </g>
          <path d="M25 -16C25 -17.1046 25.8954 -18 27 -18H43C44.1046 -18 45 -17.1046 45 -16V0.763931C45 1.52147 44.572 2.214 43.8944 2.55279L35.8944 6.55279C35.3314 6.83431 34.6686 6.83431 34.1056 6.55279L26.1056 2.55279C25.428 2.214 25 1.52148 25 0.763931V-16Z" fill="#DD62D8"/>
          <path d="M45 84C45 85.1046 44.1046 86 43 86L27 86C25.8954 86 25 85.1046 25 84L25 67.2361C25 66.4785 25.428 65.786 26.1056 65.4472L34.1056 61.4472C34.6686 61.1657 35.3314 61.1657 35.8944 61.4472L43.8944 65.4472C44.572 65.786 45 66.4785 45 67.2361L45 84Z" fill="#DD62D8"/>
          </g>
          <rect x="0.5" y="0.5" width="261" height="67.3478" rx="6.73118" stroke="#DD62D8"/>
          <defs>
          <filter id="filter0_f_51_1402" x="-323" y="-388.186" width="665" height="665" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
          <feFlood flood-opacity="0" result="BackgroundImageFix"/>
          <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
          <feGaussianBlur stdDeviation="119.5" result="effect1_foregroundBlur_51_1402"/>
          </filter>
          <filter id="filter1_f_51_1402" x="-571.994" y="12.8197" width="1365.99" height="1365.99" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
          <feFlood flood-opacity="0" result="BackgroundImageFix"/>
          <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
          <feGaussianBlur stdDeviation="200.497" result="effect1_foregroundBlur_51_1402"/>
          </filter>
          <linearGradient id="paint0_linear_51_1402" x1="4.28828" y1="7.12885" x2="78.5337" y2="158.981" gradientUnits="userSpaceOnUse">
          <stop stop-color="#000103"/>
          <stop offset="1" stop-color="#010104"/>
          </linearGradient>
          <clipPath id="clip0_51_1402">
          <rect width="262" height="68.3478" rx="7.23118" fill="white"/>
          </clipPath>
          </defs>
          </svg>           
      </div>
          `
        );
        // Delete İtem And Anim
        let item = document.getElementById(number);
        gsap.to(item, { left: 0, duration: 0.5, ease: "power2.out" });
        gsap.to(item, {
          left: "-20vw",
          duration: 0.5,
          ease: "power2.out",
          delay: delayA,
        });
        setTimeout(() => {
          item.remove();
        }, this.notifyDelay);
      } else if (type === "quest") {
        // div append innerhtml
        var number = Math.floor(Math.random() * 1000 + 1);
        notify.insertAdjacentHTML(
          "beforeend",
          `
          <div class="notfiyC quest" id="${number}">
          <div class="cont">
              <div class="icon">
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M11.7464 0C9.42322 0 7.15216 0.688917 5.22047 1.97963C3.28878 3.27035 1.78321 5.10489 0.89415 7.25127C0.00508955 9.39765 -0.227529 11.7595 0.22571 14.0381C0.678949 16.3166 1.79769 18.4097 3.44046 20.0524C5.08323 21.6952 7.17624 22.8139 9.45483 23.2672C11.7334 23.7204 14.0952 23.4878 16.2416 22.5987C18.388 21.7097 20.2225 20.2041 21.5133 18.2724C22.804 16.3407 23.4929 14.0697 23.4929 11.7464C23.4896 8.6321 22.251 5.64626 20.0488 3.44408C17.8466 1.24191 14.8608 0.0032888 11.7464 0ZM11.7464 18.975C11.4784 18.975 11.2163 18.8955 10.9934 18.7466C10.7706 18.5977 10.5968 18.386 10.4943 18.1383C10.3917 17.8907 10.3648 17.6182 10.4171 17.3552C10.4694 17.0923 10.5985 16.8508 10.7881 16.6613C10.9776 16.4717 11.2191 16.3426 11.482 16.2903C11.7449 16.238 12.0175 16.2649 12.2651 16.3675C12.5128 16.4701 12.7245 16.6438 12.8734 16.8667C13.0223 17.0896 13.1018 17.3516 13.1018 17.6197C13.1018 17.9791 12.959 18.3239 12.7048 18.578C12.4506 18.8322 12.1059 18.975 11.7464 18.975ZM12.65 13.4723V13.5536C12.65 13.7932 12.5548 14.0231 12.3854 14.1925C12.2159 14.362 11.9861 14.4572 11.7464 14.4572C11.5068 14.4572 11.277 14.362 11.1075 14.1925C10.9381 14.0231 10.8429 13.7932 10.8429 13.5536V12.65C10.8429 12.4104 10.9381 12.1805 11.1075 12.0111C11.277 11.8416 11.5068 11.7464 11.7464 11.7464C13.2407 11.7464 14.4572 10.7299 14.4572 9.48751C14.4572 8.2451 13.2407 7.22858 11.7464 7.22858C10.2522 7.22858 9.03573 8.2451 9.03573 9.48751V9.93929C9.03573 10.1789 8.94053 10.4088 8.77108 10.5782C8.60162 10.7477 8.3718 10.8429 8.13216 10.8429C7.89251 10.8429 7.66269 10.7477 7.49323 10.5782C7.32378 10.4088 7.22858 10.1789 7.22858 9.93929V9.48751C7.22858 7.24552 9.25484 5.42143 11.7464 5.42143C14.238 5.42143 16.2643 7.24552 16.2643 9.48751C16.2643 11.4505 14.7102 13.0939 12.65 13.4723Z" fill="#D2D2D2"/>
              </svg>              
              </div>
              <div class="text">
                  <h1>${this.notifyText.quest}</h1>
                  <p>${text}</p>
              </div>
          </div>
          <svg width="262" height="69" viewBox="0 0 262 69" fill="none" xmlns="http://www.w3.org/2000/svg">
          <g clip-path="url(#clip0_51_1446)">
          <rect width="262" height="68.3478" rx="7.23118" fill="url(#paint0_linear_51_1446)"/>
          <g filter="url(#filter0_f_51_1446)">
          <circle cx="9.5" cy="-55.686" r="93.5" fill="white" fill-opacity="0.25"/>
          </g>
          <g filter="url(#filter1_f_51_1446)">
          <circle cx="111" cy="695.814" r="282" fill="#876544" fill-opacity="0.22"/>
          </g>
          <path d="M25 -16C25 -17.1046 25.8954 -18 27 -18H43C44.1046 -18 45 -17.1046 45 -16V0.763931C45 1.52147 44.572 2.214 43.8944 2.55279L35.8944 6.55279C35.3314 6.83431 34.6686 6.83431 34.1056 6.55279L26.1056 2.55279C25.428 2.214 25 1.52148 25 0.763931V-16Z" fill="#D2D2D2"/>
          <path d="M45 84C45 85.1046 44.1046 86 43 86L27 86C25.8954 86 25 85.1046 25 84L25 67.2361C25 66.4785 25.428 65.786 26.1056 65.4472L34.1056 61.4472C34.6686 61.1657 35.3314 61.1657 35.8944 61.4472L43.8944 65.4472C44.572 65.786 45 66.4785 45 67.2361L45 84Z" fill="#D2D2D2"/>
          </g>
          <rect x="0.5" y="0.5" width="261" height="67.3478" rx="6.73118" stroke="#D2D2D2"/>
          <defs>
          <filter id="filter0_f_51_1446" x="-323" y="-388.186" width="665" height="665" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
          <feFlood flood-opacity="0" result="BackgroundImageFix"/>
          <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
          <feGaussianBlur stdDeviation="119.5" result="effect1_foregroundBlur_51_1446"/>
          </filter>
          <filter id="filter1_f_51_1446" x="-571.994" y="12.8197" width="1365.99" height="1365.99" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
          <feFlood flood-opacity="0" result="BackgroundImageFix"/>
          <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
          <feGaussianBlur stdDeviation="200.497" result="effect1_foregroundBlur_51_1446"/>
          </filter>
          <linearGradient id="paint0_linear_51_1446" x1="4.28828" y1="7.12885" x2="78.5337" y2="158.981" gradientUnits="userSpaceOnUse">
          <stop stop-color="#000103"/>
          <stop offset="1" stop-color="#010104"/>
          </linearGradient>
          <clipPath id="clip0_51_1446">
          <rect width="262" height="68.3478" rx="7.23118" fill="white"/>
          </clipPath>
          </defs>
          </svg>                  
      </div>
          `
        );
        // Delete İtem And Anim
        let item = document.getElementById(number);
        gsap.to(item, { left: 0, duration: 0.5, ease: "power2.out" });
        gsap.to(item, {
          left: "-20vw",
          duration: 0.5,
          ease: "power2.out",
          delay: delayA,
        });
        setTimeout(() => {
          item.remove();
        }, this.notifyDelay);
      }
    },
  },

  created() {
    window.addEventListener("keydown", this.mechanicRotate);
  },
  beforeDestroy() {
    window.removeEventListener("keydown", this.mechanicRotate);
  },

  watch: {
    // Boss Menu
    "bossMenu.depositMoney": function (val) {
      if (val < 0) {
        this.bossMenu.depositMoney = 0;
      }
    },
    "bossMenu.newDiscount": function (val) {
      if (val < 0) {
        this.bossMenu.newDiscount = null;
      }
    },
    "bossMenu.newWashPrice": function (val) {
      if (val < 0) {
        this.bossMenu.newWashPrice = null;
      }
    },

    // Mechanic Menu
    "mechanicMenu.activeIndex": function (val) {
      hover = this.mechanicMenu.categories[val]
      if (hover && hover !== undefined) {
        if (hover.type == "item") {
          this.post('hoverModel', hover)
        }
      }
    },
    "mechanicMenu.status": {
        handler: function (val, oldVal) {
            Status(val.circle1, val.circle2, val.circle3, val.circle4, "update");
        },
        deep: true,
    },
    "mechanicMenu.panelView": function (val) {
      if (val) {
            this.mechanicMenu.colorMenu = false;
            this.mechanicMenu.cardOpen = false;
        }
    },
    "mechanicMenu.colorMenu": function (val) {
        if (val) {
            this.mechanicMenu.panelView = false;
            this.mechanicMenu.cardOpen = false;
        } else {
            this.mechanicMenu.panelView = true;
        }
      },
      "mechanicMenu.cardOpen": function (val) {
        if (val) {
            this.mechanicMenu.panelView = false;
            this.mechanicMenu.colorMenu = false;
          } else {
            this.mechanicMenu.panelView = true;
          }
        },
    
    // Fitment Menu
    "fitMenu.fitMenu": {
      handler: function (val, oldVal) {
          val.forEach(e => {
            this.post('changeFitment', e)
          })
      },
      deep: true,
    },
    "fitMenu.enabled": function (val) {
      if (val) {
        this.mechanicMenu.panelView = false;
      } else {
        this.mechanicMenu.panelView = true;
      }
    },
    // Tuning Menu
    "tuningMenu.rainbowNeon": function (val) {
      this.tuningMenu.rainbowNeon = val
      if (val) {
        gsap.to(".select-circle.neon .circle", { duration: 0.3, left: "90%", ease: "power2.inOut", background: "linear-gradient(90deg, #FF3667 0%, #FF36BB 23.33%, #FF36DF 47.81%, #D736FF 72.81%, #B336FF 100%)" });
      }
      else if (!val) {
        gsap.to(".select-circle.neon .circle", { duration: 0.3, left: "0%", ease: "power2.inOut", background: "linear-gradient(90deg, #A9A9A9 0%, #A9A9A9 23.33%, #A9A9A9 47.81%, #A9A9A9 72.81%, #A9A9A9 100%)" });
      }
    },
    "tuningMenu.rainbowHeadlights": function (val) {
      this.tuningMenu.rainbowHeadlights = val
      if (val) {
        gsap.to(".select-circle.headlights .circle", { duration: 0.3, left: "88%", ease: "power2.inOut", background: "linear-gradient(90deg, #FF3667 0%, #FF36BB 23.33%, #FF36DF 47.81%, #D736FF 72.81%, #B336FF 100%)" });
      }
      else if (!val) {
        gsap.to(".select-circle.headlights .circle", { duration: 0.3, left: "0%", ease: "power2.inOut", background: "linear-gradient(90deg, #A9A9A9 0%, #A9A9A9 23.33%, #A9A9A9 47.81%, #A9A9A9 72.81%, #A9A9A9 100%)" });
      }
    },
  },
});

window.addEventListener("keydown", function (e) {
  if (e.key === "Escape") {
    if (menuOpened) return;
    app.openUI("boss", false);
    app.openUI("tuning", false);
    app.openUI("craft", false);
    post('closeCraft');
    app.openContext(false, "lift");
    app.openContext(false, "flatbed");
    menuOpened = false;
    post('closeUI')
  } else if (e.key === "Shift") {
    if (!menuOpened) return;
    post('freeCam', {bool: true, isFitment : app.fitMenu.enabled})
  }
});

function post(event, data) {
  var xhr = new XMLHttpRequest();
  xhr.open("POST", "https://dusa_mechanic/" + event);
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.onreadystatechange = function () {
    if (xhr.readyState === 4 && xhr.status === 200) {
    }
  };
  xhr.send(JSON.stringify({ data }));
}