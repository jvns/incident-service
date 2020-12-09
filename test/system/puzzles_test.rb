require "application_system_test_case"

class PuzzlesTest < ApplicationSystemTestCase
  setup do
    @puzzle = puzzles(:one)
  end

  test "visiting the index" do
    visit puzzles_url
    assert_selector "h1", text: "Puzzles"
  end

  test "creating a Puzzle" do
    visit puzzles_url
    click_on "New Puzzle"

    fill_in "Cloud init", with: @puzzle.cloud_init
    fill_in "Title", with: @puzzle.title
    click_on "Create Puzzle"

    assert_text "Puzzle was successfully created"
    click_on "Back"
  end

  test "updating a Puzzle" do
    visit puzzles_url
    click_on "Edit", match: :first

    fill_in "Cloud init", with: @puzzle.cloud_init
    fill_in "Title", with: @puzzle.title
    click_on "Update Puzzle"

    assert_text "Puzzle was successfully updated"
    click_on "Back"
  end

  test "destroying a Puzzle" do
    visit puzzles_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Puzzle was successfully destroyed"
  end
end
