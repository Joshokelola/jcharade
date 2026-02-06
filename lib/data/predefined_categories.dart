import '../models/word.dart';
import '../models/category.dart';

/// Contains all predefined categories with general gameplay focus
class PredefinedCategories {
  static final List<Category> all = [
    // Everyday Actions
    everydayActionsEasy,
    everydayActionsMedium,
    everydayActionsHard,
    // Household Items
    householdItemsEasy,
    householdItemsMedium,
    householdItemsHard,
    // Sports and Fitness
    sportsAndFitnessEasy,
    sportsAndFitnessMedium,
    sportsAndFitnessHard,

    objectsAndCreaturesEasy,
    mixedEasy
  ];

  // ==========================================
  // Category 1: Everyday Actions
  // ==========================================

  static final Category everydayActionsEasy = Category(
    id: 'everyday_actions_easy',
    name: 'Everyday Actions (Easy)',
    description: 'Simple daily tasks anyone can act out',
    icon: '🏃',
    words: const [
      Word(text: 'Brushing Teeth', hint: 'Morning routine', difficulty: 1),
      Word(text: 'Tying Shoes', hint: 'Laces tight', difficulty: 1),
      Word(text: 'Drinking Water', hint: 'Stay hydrated', difficulty: 1),
      Word(text: 'Making Bed', hint: 'Smooth the sheets', difficulty: 1),
      Word(text: 'Eating Cereal', hint: 'Breakfast bowl', difficulty: 1),
      Word(text: 'Clapping Hands', hint: 'Applause time', difficulty: 1),
      Word(text: 'Taking Notes', hint: 'Pen and paper', difficulty: 1),
      Word(text: 'Stretching Arms', hint: 'Wake-up move', difficulty: 1),
      Word(text: 'Petting Cat', hint: 'Soft fur friend', difficulty: 1),
      Word(text: 'Checking Mail', hint: 'Mailbox peek', difficulty: 1),
      Word(text: 'Watering Plants', hint: 'Keep them green', difficulty: 1),
      Word(text: 'Packing Bag', hint: 'Ready to go', difficulty: 1),
      Word(text: 'Opening Door', hint: 'Turn the knob', difficulty: 1),
      Word(text: 'Waving Hello', hint: 'Friendly greeting', difficulty: 1),
      Word(text: 'Sweeping Floor', hint: 'Broom in hand', difficulty: 1),
      Word(text: 'Buttoning Shirt', hint: 'Tiny circles', difficulty: 1),
      Word(text: 'Combing Hair', hint: 'Tame the tangles', difficulty: 1),
      Word(text: 'Posting Letter', hint: 'Mail slot drop', difficulty: 1),
      Word(text: 'Pouring Juice', hint: 'Fill the glass', difficulty: 1),
      Word(text: 'Reading Book', hint: 'Turn the page', difficulty: 1),
    ],
  );

  static final Category everydayActionsMedium = Category(
    id: 'everyday_actions_medium',
    name: 'Everyday Actions (Medium)',
    description: 'Slightly more expressive daily routines',
    icon: '🧭',
    words: const [
      Word(text: 'Folding Laundry', hint: 'Stack the shirts', difficulty: 2),
      Word(text: 'Wrapping Gift', hint: 'Ribbon and paper', difficulty: 2),
      Word(text: 'Planting Herbs', hint: 'Garden box', difficulty: 2),
      Word(text: 'Mixing Batter', hint: 'Whisk in bowl', difficulty: 2),
      Word(text: 'Assembling Chair', hint: 'IKEA mode', difficulty: 2),
      Word(text: 'Ironing Pants', hint: 'Steam away wrinkles', difficulty: 2),
      Word(text: 'Cleaning Window', hint: 'Spray and wipe', difficulty: 2),
      Word(text: 'Setting Timer', hint: 'Kitchen countdown', difficulty: 2),
      Word(text: 'Sharpening Pencil', hint: 'Twist to point', difficulty: 2),
      Word(text: 'Hanging Picture', hint: 'Frame on wall', difficulty: 2),
      Word(text: 'Replacing Bulb', hint: 'Twist in socket', difficulty: 2),
      Word(text: 'Checking Pulse', hint: 'Wrist tap', difficulty: 2),
      Word(text: 'Rolling Dough', hint: 'Pastry prep', difficulty: 2),
      Word(text: 'Tuning Guitar', hint: 'Tighten strings', difficulty: 2),
      Word(text: 'Filtering Coffee', hint: 'Pour-over brew', difficulty: 2),
      Word(text: 'Filing Papers', hint: 'Organize docs', difficulty: 2),
      Word(text: 'Sorting Packages', hint: 'Stack the boxes', difficulty: 2),
      Word(text: 'Stretching Canvas', hint: 'Art frame prep', difficulty: 2),
      Word(text: 'Checking Tires', hint: 'Kick the wheels', difficulty: 2),
      Word(text: 'Packing Groceries', hint: 'Bag the haul', difficulty: 2),
    ],
  );

  static final Category everydayActionsHard = Category(
    id: 'everyday_actions_hard',
    name: 'Everyday Actions (Hard)',
    description: 'Complex actions requiring detailed charades',
    icon: '🧠',
    words: const [
      Word(text: 'Changing Tire', hint: 'Lug nuts and jack', difficulty: 3),
      Word(text: 'Juggling Balls', hint: 'Keep them in air', difficulty: 3),
      Word(text: 'Unclogging Sink', hint: 'Plunger action', difficulty: 3),
      Word(text: 'Painting Ceiling', hint: 'Roller on pole', difficulty: 3),
      Word(text: 'Applying Makeup', hint: 'Mirror and brush', difficulty: 3),
      Word(text: 'Riding Unicycle', hint: 'One wheel balance', difficulty: 3),
      Word(text: 'Assembling Computer', hint: 'Tiny screws', difficulty: 3),
      Word(text: 'Playing Violin', hint: 'Bow and chin', difficulty: 3),
      Word(text: 'Flying Kite', hint: 'Wind and string', difficulty: 3),
      Word(text: 'Knitting Sweater', hint: 'Needles and yarn', difficulty: 3),
      Word(text: 'Backing Trailer', hint: 'Steer backwards', difficulty: 3),
      Word(text: 'Mixing Cocktails', hint: 'Shaker and ice', difficulty: 3),
      Word(text: 'Operating Crane', hint: 'Joysticks', difficulty: 3),
      Word(text: 'Fencing Match', hint: 'Parry and thrust', difficulty: 3),
      Word(text: 'Sculpting Clay', hint: 'Wheel and mud', difficulty: 3),
      Word(text: 'Tying Tie', hint: 'Neck knot', difficulty: 3),
      Word(text: 'Slicing Sushi', hint: 'Sharp knife', difficulty: 3),
      Word(text: 'Performing Magic', hint: 'Card trick', difficulty: 3),
      Word(text: 'Walking Tightrope', hint: 'Balance pole', difficulty: 3),
      Word(text: 'CPR', hint: 'Chest compressions', difficulty: 3),
    ],
  );

  // ==========================================
  // Category 2: Household Items
  // ==========================================

  static final Category householdItemsEasy = Category(
    id: 'household_items_easy',
    name: 'Household Items (Easy)',
    description: 'Common objects found around the home',
    icon: '🏠',
    words: const [
      Word(text: 'Sofa', hint: 'Living room seat', difficulty: 1),
      Word(text: 'Lamp', hint: 'Bright idea', difficulty: 1),
      Word(text: 'Teapot', hint: 'Brews leaves', difficulty: 1),
      Word(text: 'Pillow', hint: 'Headrest', difficulty: 1),
      Word(text: 'Mirror', hint: 'Look at you', difficulty: 1),
      Word(text: 'Broom', hint: 'Sweeping stick', difficulty: 1),
      Word(text: 'Clock', hint: 'Ticks away', difficulty: 1),
      Word(text: 'Mug', hint: 'Coffee cup', difficulty: 1),
      Word(text: 'Plate', hint: 'Dinner circle', difficulty: 1),
      Word(text: 'Blanket', hint: 'Cozy cover', difficulty: 1),
      Word(text: 'Curtain', hint: 'Window cloth', difficulty: 1),
      Word(text: 'Notebook', hint: 'Paper pages', difficulty: 1),
      Word(text: 'Remote', hint: 'Channel changer', difficulty: 1),
      Word(text: 'Basket', hint: 'Carry things', difficulty: 1),
      Word(text: 'Doorbell', hint: 'Entry chime', difficulty: 1),
      Word(text: 'Toaster', hint: 'Morning crisp', difficulty: 1),
      Word(text: 'Window', hint: 'Glass view', difficulty: 1),
      Word(text: 'Candle', hint: 'Wax light', difficulty: 1),
      Word(text: 'Keychain', hint: 'Holds keys', difficulty: 1),
      Word(text: 'Picture Frame', hint: 'Display photo', difficulty: 1),
    ],
  );

  static final Category householdItemsMedium = Category(
    id: 'household_items_medium',
    name: 'Household Items (Medium)',
    description: 'Detailed household gear for extra challenge',
    icon: '🛠️',
    words: const [
      Word(text: 'Pressure Cooker', hint: 'Fast stew pot', difficulty: 2),
      Word(text: 'Measuring Tape', hint: 'Lengths on ribbon', difficulty: 2),
      Word(text: 'Extension Cord', hint: 'Extra reach plug', difficulty: 2),
      Word(text: 'Photo Album', hint: 'Memories book', difficulty: 2),
      Word(text: 'Wireless Speaker', hint: 'Bluetooth beats', difficulty: 2),
      Word(text: 'Power Drill', hint: 'Rotating tool', difficulty: 2),
      Word(text: 'Spice Rack', hint: 'Herb shelf', difficulty: 2),
      Word(text: 'Laundry Hamper', hint: 'Clothes basket', difficulty: 2),
      Word(text: 'Table Runner', hint: 'Decor strip', difficulty: 2),
      Word(text: 'Storage Bin', hint: 'Plastic tote', difficulty: 2),
      Word(text: 'Blender Jar', hint: 'Smoothie container', difficulty: 2),
      Word(text: 'Floor Cushion', hint: 'Low seat', difficulty: 2),
      Word(text: 'Reading Lamp', hint: 'Focused light', difficulty: 2),
      Word(text: 'Garden Shears', hint: 'Trim plants', difficulty: 2),
      Word(text: 'Water Filter', hint: 'Pitcher insert', difficulty: 2),
      Word(text: 'Clothes Steamer', hint: 'Wrinkle release', difficulty: 2),
      Word(text: 'Drying Rack', hint: 'Air clothes', difficulty: 2),
      Word(text: 'Coffee Grinder', hint: 'Beans to grounds', difficulty: 2),
      Word(text: 'Air Purifier', hint: 'Fresh airflow', difficulty: 2),
      Word(text: 'Wall Hooks', hint: 'Hang coats', difficulty: 2),
    ],
  );

  static final Category householdItemsHard = Category(
    id: 'household_items_hard',
    name: 'Household Items (Hard)',
    description: 'Niche items or hard-to-act objects',
    icon: '📦',
    words: const [
      Word(text: 'Thermostat', hint: 'Temp control', difficulty: 3),
      Word(text: 'Fire Extinguisher', hint: 'Red cylinder', difficulty: 3),
      Word(text: 'Humidifier', hint: 'Mist maker', difficulty: 3),
      Word(text: 'Screwdriver Set', hint: 'Flat and phillips', difficulty: 3),
      Word(text: 'Sewing Machine', hint: 'Pedal and needle', difficulty: 3),
      Word(text: 'Ironing Board', hint: 'Foldable table', difficulty: 3),
      Word(text: 'Garbage Disposal', hint: 'Sink grinder', difficulty: 3),
      Word(text: 'Router', hint: 'Wi-Fi box', difficulty: 3),
      Word(text: 'Ceiling Fan', hint: 'High breeze', difficulty: 3),
      Word(text: 'Safe', hint: 'Combo lock box', difficulty: 3),
      Word(text: 'Projector', hint: 'Movie light', difficulty: 3),
      Word(text: 'Dehydrator', hint: 'Fruit dryer', difficulty: 3),
      Word(text: 'Lawnmower', hint: 'Grass cutter', difficulty: 3),
      Word(text: 'Bread Maker', hint: 'Loaf machine', difficulty: 3),
      Word(text: 'Telescope', hint: 'Star gazer', difficulty: 3),
      Word(text: 'Microscope', hint: 'Small world', difficulty: 3),
      Word(text: 'Safe', hint: 'Valuables box', difficulty: 3),
      Word(text: 'Guitar Amp', hint: 'Loud speaker', difficulty: 3),
      Word(text: 'Record Player', hint: 'Vinyl spinner', difficulty: 3),
      Word(text: 'Water Softener', hint: 'Tank', difficulty: 3),
    ],
  );

  // ==========================================
  // Category 3: Sports & Fitness
  // ==========================================

  static final Category sportsAndFitnessEasy = Category(
    id: 'sports_fitness_easy',
    name: 'Sports & Fitness (Easy)',
    description: 'Beginner-friendly gear and moves',
    icon: '⚽',
    words: const [
      Word(text: 'Soccer Ball', hint: 'Goal kicks', difficulty: 1),
      Word(text: 'Basketball', hint: 'Court bounce', difficulty: 1),
      Word(text: 'Tennis Racket', hint: 'String paddle', difficulty: 1),
      Word(text: 'Baseball Bat', hint: 'Swing away', difficulty: 1),
      Word(text: 'Jump Rope', hint: 'Skip rhythm', difficulty: 1),
      Word(text: 'Yoga Mat', hint: 'Stretch space', difficulty: 1),
      Word(text: 'Swim Goggles', hint: 'Pool eyes', difficulty: 1),
      Word(text: 'Running Shoes', hint: 'Track sneakers', difficulty: 1),
      Word(text: 'Cycling Helmet', hint: 'Bike safety', difficulty: 1),
      Word(text: 'Hiking Boots', hint: 'Trail steps', difficulty: 1),
      Word(text: 'Boxing Gloves', hint: 'Ring fists', difficulty: 1),
      Word(text: 'Ski Poles', hint: 'Snow balance', difficulty: 1),
      Word(text: 'Golf Club', hint: 'Fairway swing', difficulty: 1),
      Word(text: 'Dance Shoes', hint: 'Studio steps', difficulty: 1),
      Word(text: 'Surf Board', hint: 'Ride waves', difficulty: 1),
      Word(text: 'Pingpong Paddle', hint: 'Table rally', difficulty: 1),
      Word(text: 'Frisbee Disc', hint: 'Park toss', difficulty: 1),
      Word(text: 'Water Bottle', hint: 'Gym sip', difficulty: 1),
      Word(text: 'Stretch Band', hint: 'Resistance pull', difficulty: 1),
      Word(text: 'Stopwatch', hint: 'Lap timer', difficulty: 1),
    ],
  );

  static final Category sportsAndFitnessMedium = Category(
    id: 'sports_fitness_medium',
    name: 'Sports & Fitness (Medium)',
    description: 'Dynamic moves for a bit more challenge',
    icon: '🏃',
    words: const [
      Word(text: 'Interval Sprint', hint: 'Timed bursts', difficulty: 2),
      Word(text: 'Trail Running', hint: 'Forest jog', difficulty: 2),
      Word(text: 'Rock Climb', hint: 'Vertical grip', difficulty: 2),
      Word(text: 'Powerlifting', hint: 'Heavy bar', difficulty: 2),
      Word(text: 'Martial Arts', hint: 'Sparring stance', difficulty: 2),
      Word(text: 'Mountain Biking', hint: 'Rugged ride', difficulty: 2),
      Word(text: 'Rowing Stroke', hint: 'Crew pull', difficulty: 2),
      Word(text: 'Figure Skating', hint: 'Ice dance', difficulty: 2),
      Word(text: 'Pole Vault', hint: 'Bar leap', difficulty: 2),
      Word(text: 'Beach Volleyball', hint: 'Sand spike', difficulty: 2),
      Word(text: 'Crossfit Circuit', hint: 'Box workout', difficulty: 2),
      Word(text: 'Speed Skating', hint: 'Fast glide', difficulty: 2),
      Word(text: 'Weight Training', hint: 'Rep it out', difficulty: 2),
      Word(text: 'Goalie Save', hint: 'Dive for ball', difficulty: 2),
      Word(text: 'Relay Baton', hint: 'Pass and dash', difficulty: 2),
      Word(text: 'Yoga Inversion', hint: 'Upside pose', difficulty: 2),
      Word(text: 'Kickboxing Combo', hint: 'Punch and kick', difficulty: 2),
      Word(text: 'Rowing Machine', hint: 'Indoor crew', difficulty: 2),
      Word(text: 'Balance Beam', hint: 'Gymnastics rail', difficulty: 2),
      Word(text: 'Sprint Start', hint: 'Blocks push', difficulty: 2),
    ],
  );

  static final Category sportsAndFitnessHard = Category(
    id: 'sports_fitness_hard',
    name: 'Sports & Fitness (Hard)',
    description: 'Specific techniques and obscure sports',
    icon: '🏆',
    words: const [
      Word(text: 'Synchronized Swim', hint: 'Underwater team', difficulty: 3),
      Word(text: 'Curling Stone', hint: 'Ice sweeping', difficulty: 3),
      Word(text: 'Skydiving', hint: 'Freefall', difficulty: 3),
      Word(text: 'Bobsledding', hint: 'Ice track sled', difficulty: 3),
      Word(text: 'Fencing Parry', hint: 'Sword block', difficulty: 3),
      Word(text: 'Archery Draw', hint: 'Bow and arrow', difficulty: 3),
      Word(text: 'Horseback Riding', hint: 'Trot and canter', difficulty: 3),
      Word(text: 'Javelin Throw', hint: 'Spear toss', difficulty: 3),
      Word(text: 'Steeplechase', hint: 'Hurdles and water', difficulty: 3),
      Word(text: 'Discus Throw', hint: 'Spin and fling', difficulty: 3),
      Word(text: 'Hammer Throw', hint: 'Heavy ball spin', difficulty: 3),
      Word(text: 'Triathlon Transition', hint: 'Bike to run', difficulty: 3),
      Word(text: 'Surfing Barrel', hint: 'Inside the wave', difficulty: 3),
      Word(text: 'Ski Jump', hint: 'Long air time', difficulty: 3),
      Word(text: 'Luge', hint: 'Feet first sled', difficulty: 3),
      Word(text: 'Badminton Smash', hint: 'Shuttlecock', difficulty: 3),
      Word(text: 'Water Polo', hint: 'One hand throw', difficulty: 3),
      Word(text: 'Decathlon', hint: 'Ten events', difficulty: 3),
      Word(text: 'Jai Alai', hint: 'Fastest sport', difficulty: 3),
      Word(text: 'Formula 1 Pitstop', hint: 'Wheel change', difficulty: 3),
    ],
  );

  static final Category objectsAndCreaturesEasy = Category(
    id: 'objects_creatures_easy',
    name: 'Objects & Creatures (Easy)',
    description: 'A mix of common items and animals to act out',
    icon: '🐙',
    words: const [
      Word(text: 'Pen', hint: 'Write with it', difficulty: 1),
      Word(text: 'Bird', hint: 'Flap wings', difficulty: 1),
      Word(text: 'Skateboard', hint: 'Wheels on board', difficulty: 1),
      Word(text: 'Dog', hint: 'Bark and tail wag', difficulty: 1),
      Word(text: 'Chicken', hint: 'Cluck and peck', difficulty: 1),
      Word(text: 'Lion', hint: 'Roar loudly', difficulty: 1),
      Word(text: 'Grass', hint: 'Grow from ground', difficulty: 1),
      Word(text: 'Worm', hint: 'Wriggle on floor', difficulty: 1),
      Word(text: 'Bunny', hint: 'Hop and twitch nose', difficulty: 1),
      Word(text: 'Basketball', hint: 'Dribble and shoot', difficulty: 1),
      Word(text: 'Lollipop', hint: 'Lick sweet treat', difficulty: 1),
      Word(text: 'Bench', hint: 'Sit in park', difficulty: 1),
      Word(text: 'Bridge', hint: 'Cross over water', difficulty: 1),
      Word(text: 'Island', hint: 'Land in ocean', difficulty: 1),
      Word(text: 'Carrot', hint: 'Crunchy orange food', difficulty: 1),
      Word(text: 'Comb', hint: 'Fix hair', difficulty: 1),
      Word(text: 'Car', hint: 'Steer steering wheel', difficulty: 1),
      Word(text: 'Pig', hint: 'Oink and snout', difficulty: 1),
      Word(text: 'Balloon', hint: 'Float in air', difficulty: 1),
      Word(text: 'Sea Turtle', hint: 'Swim slowly', difficulty: 1),
    ],
  );

  static final Category mixedEasy = Category(
    id: 'mixed_easy',
    name: 'Mixed Bag (Easy)',
    description: 'A random collection of easy things to act',
    icon: '🎲',
    words: const [
      Word(text: 'Forehead', hint: 'Point to it', difficulty: 1),
      Word(text: 'T-shirt', hint: 'Clothing item', difficulty: 1),
      Word(text: 'Sidewalk', hint: 'Walking path', difficulty: 1),
      Word(text: 'Bathroom Scale', hint: 'Check weight', difficulty: 1),
      Word(text: 'Pocket', hint: 'On your pants', difficulty: 1),
      Word(text: 'Seesaw', hint: 'Playground up and down', difficulty: 1),
      Word(text: 'Minivan', hint: 'Family car', difficulty: 1),
      Word(text: 'TV', hint: 'Watch screen', difficulty: 1),
      Word(text: 'Stove', hint: 'Cooking appliance', difficulty: 1),
      Word(text: 'Marshmallow', hint: 'Roast over fire', difficulty: 1),
      Word(text: 'Fin', hint: 'Fish part', difficulty: 1),
      Word(text: 'Bacteria', hint: 'Microscopic bug', difficulty: 1),
      Word(text: 'Pet', hint: 'Animal friend', difficulty: 1),
      Word(text: 'Chalk', hint: 'Draw on sidewalk', difficulty: 1),
      Word(text: 'Picture Frame', hint: 'Hang on wall', difficulty: 1),
      Word(text: 'Curtain', hint: 'Window cover', difficulty: 1),
      Word(text: 'Notepad', hint: 'Write list', difficulty: 1),
      Word(text: 'Camera', hint: 'Take photo', difficulty: 1),
      Word(text: 'Squirt Gun', hint: 'Water toy', difficulty: 1),
      Word(text: 'Slide', hint: 'Playground fun', difficulty: 1),
    ],
  );

  // ==========================================
  // Helper Methods
  // ==========================================

  static Category? getCategoryById(String id) {
    try {
      return all.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<String> getAllCategoryNames() {
    return all.map((category) => category.name).toList();
  }

  static int getTotalWordCount() {
    return all.fold(0, (sum, category) => sum + category.wordCount);
  }
}