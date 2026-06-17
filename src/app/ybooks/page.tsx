import { redirect } from "next/navigation";

export default function YBooksPage() {
  redirect("/bookmarks?source=yt");
}
