module NavigationHelper
  # Paths become real routes with #72, #77, #92
  def main_navigation_items
    [
      { key: :calendar, label: "Kalendár", path: "#" },
      { key: :reservations, label: "Moje rezervácie", short_label: "Rezervácie", path: "#" },
      { key: :board, label: "Nástenka", path: "#" },
      { key: :photos, label: "Fotky", path: "#" },
      { key: :profile, label: "Profil", path: "#" }
    ]
  end
end
