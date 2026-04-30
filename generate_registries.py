import json

olympic_sports = [
    ("Archery", "archery", "archery", "archery"),
    ("Artistic Gymnastics", "artistic-gymnastics", "gymnastics", "artistic-gymnastics"),
    ("Artistic Swimming", "artistic-swimming", "swimming", "artistic-swimming"),
    ("Badminton", "badminton", "badminton", "badminton"),
    ("Baseball", "baseball", "baseball", "baseball"),
    ("Basketball", "basketball", "basketball", "basketball"),
    ("3x3 Basketball", "basketball-3x3", "basketball", "basketball-3x3"),
    ("Beach Volleyball", "beach-volleyball", "volleyball", "beach-volleyball"),
    ("BMX", "bmx", "cycling", "bmx"),
    ("Boxing", "boxing", "boxing", "boxing"),
    ("Canoe/Kayak", "canoe-kayak", "canoe-kayak", "canoe-kayak"),
    ("Climbing", "climbing", "climbing", "climbing"),
    ("Coastal Rowing", "coastal-rowing", "rowing", "coastal-rowing"),
    ("Cricket", "cricket", "cricket", "cricket"),
    ("Cycling", "cycling", "cycling", "cycling"),
    ("Diving", "diving", "swimming", "diving"),
    ("Equestrian", "equestrian", "equestrian", "equestrian"),
    ("Fencing", "fencing", "fencing", "fencing"),
    ("Field Hockey", "field-hockey", "field-hockey", "field-hockey"),
    ("Flag Football", "flag-football", "football", "flag-football"),
    ("Golf", "golf", "golf", "golf"),
    ("Handball", "handball", "handball", "handball"),
    ("Judo", "judo", "judo", "judo"),
    ("Lacrosse", "lacrosse", "lacrosse", "lacrosse"),
    ("Modern Pentathlon", "modern-pentathlon", "modern-pentathlon", "modern-pentathlon"),
    ("Mountain Bike", "mountain-bike", "cycling", "mountain-bike"),
    ("Open Water Swimming", "open-water-swimming", "swimming", "open-water-swimming"),
    ("Rhythmic Gymnastics", "rhythmic-gymnastics", "gymnastics", "rhythmic-gymnastics"),
    ("Rowing", "rowing", "rowing", "rowing"),
    ("Rugby Sevens", "rugby-sevens", "rugby", "rugby-sevens"),
    ("Sailing", "sailing", "sailing", "sailing"),
    ("Shooting", "shooting", "shooting", "shooting"),
    ("Skateboarding", "skateboarding", "skateboarding", "skateboarding"),
    ("Soccer", "soccer", "soccer", "soccer"),
    ("Softball", "softball", "softball", "softball"),
    ("Squash", "squash", "squash", "squash"),
    ("Surfing", "surfing", "surfing", "surfing"),
    ("Swimming", "swimming", "swimming", "swimming"),
    ("Table Tennis", "table-tennis", "table-tennis", "table-tennis"),
    ("Taekwondo", "taekwondo", "taekwondo", "taekwondo"),
    ("Tennis", "tennis", "tennis", "tennis"),
    ("Track and Field", "track-and-field", "track-and-field", "track-and-field"),
    ("Trampoline Gymnastics", "trampoline-gymnastics", "gymnastics", "trampoline-gymnastics"),
    ("Triathlon", "triathlon", "triathlon", "triathlon"),
    ("Volleyball", "volleyball", "volleyball", "volleyball"),
    ("Water Polo", "water-polo", "swimming", "water-polo"),
    ("Weightlifting", "weightlifting", "weightlifting", "weightlifting"),
    ("Wrestling", "wrestling", "wrestling", "wrestling")
]

paralympic_sports = [
    ("Blind Soccer", "blind-soccer", "soccer", "blind-soccer"),
    ("Boccia", "boccia", "boccia", "boccia"),
    ("Goalball", "goalball", "goalball", "goalball"),
    ("Para Archery", "para-archery", "archery", "para-archery"),
    ("Para Badminton", "para-badminton", "badminton", "para-badminton"),
    ("Paracanoe", "paracanoe", "canoe-kayak", "paracanoe"),
    ("Para Climbing", "para-climbing", "climbing", "para-climbing"),
    ("Para Cycling", "para-cycling", "cycling", "para-cycling"),
    ("Para Equestrian", "para-equestrian", "equestrian", "para-equestrian"),
    ("Para Judo", "para-judo", "judo", "para-judo"),
    ("Para Kayak", "para-kayak", "canoe-kayak", "para-kayak"),
    ("Para Powerlifting", "para-powerlifting", "powerlifting", "para-powerlifting"),
    ("Para Rowing", "para-rowing", "rowing", "para-rowing"),
    ("Para Shooting", "para-shooting", "shooting", "para-shooting"),
    ("Para Swimming", "para-swimming", "swimming", "para-swimming"),
    ("Para Table Tennis", "para-table-tennis", "table-tennis", "para-table-tennis"),
    ("Para Taekwondo", "para-taekwondo", "taekwondo", "para-taekwondo"),
    ("Para Track and Field", "para-track-and-field", "track-and-field", "para-track-and-field"),
    ("Paratriathlon", "paratriathlon", "triathlon", "paratriathlon"),
    ("Sitting Volleyball", "sitting-volleyball", "volleyball", "sitting-volleyball"),
    ("Wheelchair Basketball", "wheelchair-basketball", "basketball", "wheelchair-basketball"),
    ("Wheelchair Fencing", "wheelchair-fencing", "fencing", "wheelchair-fencing"),
    ("Wheelchair Rugby", "wheelchair-rugby", "rugby", "wheelchair-rugby"),
    ("Wheelchair Tennis", "wheelchair-tennis", "tennis", "wheelchair-tennis")
]

def make_registry(sports, bucket):
    registry = []
    for display_name, slug, family_slug, discipline_code in sports:
        status = "implemented" if slug in ["boxing", "swimming", "rowing", "equestrian"] else "stub"
        registry.append({
            "display_name": display_name,
            "slug": slug,
            "package_name": f"sport-{bucket}-{slug}",
            "bucket": bucket,
            "family_slug": family_slug,
            "sport_code": family_slug,
            "discipline_code": discipline_code,
            "source_url": "https://www.teamusa.com/los-angeles-2028/sports",
            "source_as_of": "2026-04-24",
            "status": status
        })
    return registry

olympic_registry = make_registry(olympic_sports, "olympic")
paralympic_registry = make_registry(paralympic_sports, "paralympic")

with open("sport-packs/registry/olympic-summer.json", "w") as f:
    json.dump(olympic_registry, f, indent=2)

with open("sport-packs/registry/paralympic-summer.json", "w") as f:
    json.dump(paralympic_registry, f, indent=2)

